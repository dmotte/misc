#!/usr/bin/env python3

import argparse
import difflib
import os
import shlex
import subprocess
import sys
import traceback

from contextlib import ExitStack
from dataclasses import dataclass

from lib.csvtree import tree_local, tree_snapshot, trees_equal
from lib.password_retriever import PasswordRetriever
from lib.restic_invoker import ResticInvoker
from lib.sftp_details import SFTPDetails
from lib.sshmux import ssh_mux
from lib.state import state_read, state_write


def ensure_consistent_data_state(data_dir: str, state_file: str) -> None:
    '''
    Ensures that the presence of the data dir and state file is consistent
    '''
    isdir_data = os.path.isdir(data_dir)
    exists_state = os.path.exists(state_file)

    if isdir_data and not exists_state:
        raise RuntimeError(f'Inconsistent local state: directory {data_dir} '
                           f'exists but file {state_file} doesn\'t')
    if exists_state and not isdir_data:
        raise RuntimeError(f'Inconsistent local state: file {state_file} '
                           f'exists but directory {data_dir} doesn\'t')


def resolve_snapshot_id(snapshot_id: str,
                        rinv: ResticInvoker, state: dict,
                        resolve_latest: bool = False) -> str:
    '''
    Resolves a special snapshot ID such as "latest", "state-latest", etc. to an
    actual snapshot ID
    '''
    match snapshot_id:
        case 'latest': return rinv.get_latest_snapshot_id() if resolve_latest \
            else 'latest'
        case 'state-latest': return state['latest-snapshot-id']
        case _: return snapshot_id


def check_need_pull(rinv: ResticInvoker, data_dir: str, state: dict) -> bool:
    '''
    Returns True if there are some remote changes to pull, False otherwise
    '''
    if not os.path.isdir(data_dir):
        return True

    return state['latest-snapshot-id'] != rinv.get_latest_snapshot_id()


def check_need_push(rinv: ResticInvoker, data_dir: str, state: dict) -> bool:
    '''
    Returns True if there are some local changes to push, False otherwise
    '''
    if not os.path.isdir(data_dir):
        return False

    return not trees_equal(tree_local(data_dir),
                           tree_snapshot(rinv, state['latest-snapshot-id']))

################################################################################


@dataclass
class RestsyncVars:
    '''
    The goal of this dataclass is to hold the variables needed to make
    Restsync work
    '''
    rinv: ResticInvoker
    'ResticInvoker instance'
    data_dir: str
    'Path of the local data directory'
    state_file: str
    'Path of the local state file'

################################################################################


def subcmd_restic(rsvars: RestsyncVars, args: argparse.Namespace) -> None:
    rsvars.rinv.restic(args.args)


def subcmd_init(rsvars: RestsyncVars, args: argparse.Namespace) -> None:
    if not os.path.isdir(rsvars.data_dir):
        raise RuntimeError(f'Directory {rsvars.data_dir} not found')
    if os.path.exists(rsvars.state_file):
        raise RuntimeError(f'File {rsvars.state_file} already exists')

    rsvars.rinv.restic('init')

    rsvars.rinv.restic('backup -v --skip-if-unchanged .',
                       add_popen_kwargs={'cwd': rsvars.data_dir})

    state_write(rsvars.state_file, {
        'latest-snapshot-id': rsvars.rinv.get_latest_snapshot_id()})


def subcmd_resolve(rsvars: RestsyncVars, args: argparse.Namespace) -> None:
    print(resolve_snapshot_id(
        args.snapshot_id, rsvars.rinv,
        state_read(rsvars.state_file) if args.snapshot_id.startswith('state-')
        else {}, True))


def subcmd_tree(rsvars: RestsyncVars, args: argparse.Namespace) -> None:
    it = tree_local(rsvars.data_dir) if args.snapshot_id == 'local' \
        else tree_snapshot(rsvars.rinv, resolve_snapshot_id(
            args.snapshot_id, rsvars.rinv, state_read(rsvars.state_file)
            if args.snapshot_id.startswith('state-') else {}, False))

    for line in it:
        print(line, end='')


def subcmd_diff(rsvars: RestsyncVars, args: argparse.Namespace) -> None:
    if args.id_a == args.id_b:
        return

    it_a = tree_local(rsvars.data_dir) if args.id_a == 'local' \
        else tree_snapshot(rsvars.rinv, resolve_snapshot_id(
            args.id_a, rsvars.rinv, state_read(rsvars.state_file)
            if args.id_a.startswith('state-') else {}, False))
    it_b = tree_local(rsvars.data_dir) if args.id_b == 'local' \
        else tree_snapshot(rsvars.rinv, resolve_snapshot_id(
            args.id_b, rsvars.rinv, state_read(rsvars.state_file)
            if args.id_b.startswith('state-') else {}, False))

    for line in difflib.unified_diff(list(it_a), list(it_b)):
        print(line, end='')


def subcmd_need(rsvars: RestsyncVars, args: argparse.Namespace) -> None:
    check_pull: bool = False
    check_push: bool = False
    match args.mode:
        case 'pull': check_pull = True
        case 'push': check_push = True
        case 'all': check_pull, check_push = True, True
        case _: raise ValueError(f'Invalid mode: {args.mode}')

    ensure_consistent_data_state(rsvars.data_dir, rsvars.state_file)

    state = state_read(rsvars.state_file, True)

    need_pull: bool | None = None
    need_push: bool | None = None
    if check_pull:
        print('Checking for remote changes to pull')
        need_pull = check_need_pull(rsvars.rinv, rsvars.data_dir, state)
        print(f'need-pull: {str(need_pull).lower()}')
    if check_push:
        print('Checking for local changes to push')
        need_push = check_need_push(rsvars.rinv, rsvars.data_dir, state)
        print(f'need-push: {str(need_push).lower()}')

    combination = (need_pull, need_push)
    match combination:
        case (False, None): print('No new remote changes to pull')
        case (None, False): print('No new local changes to push')
        case (True, None) | (True, False):
            print('There are some remote changes to pull')
        case (None, True) | (False, True):
            print('There are some local changes to push')
        case (False, False): print('Everything in sync')
        case (True, True): print(
            'Conflict detected! To fix: run "diff local latest", choose what '
            'to discard, and then run either "pull force" or "push force" '
            'accordingly (beware! That will discard respectively local or '
            'remote changes)')
        case _: raise ValueError(
            f'Unexpected need_pull-need_push combination: {combination}')


def subcmd_pull(rsvars: RestsyncVars, args: argparse.Namespace) -> None:
    ensure_consistent_data_state(rsvars.data_dir, rsvars.state_file)

    print('Locking restic repo')
    rsvars.rinv.lock()
    try:
        if not args.force:
            print('Ensuring that a push is not needed')
            if check_need_push(rsvars.rinv, rsvars.data_dir,
                               state_read(rsvars.state_file, True)):
                raise RuntimeError('Cannot pull: need-push is true')

        rsvars.rinv.restic(['restore', 'latest', '--delete', '-vt',
                            rsvars.data_dir])

        state_write(rsvars.state_file, {
            'latest-snapshot-id': rsvars.rinv.get_latest_snapshot_id()})
    finally:
        print('Unlocking restic repo')
        rsvars.rinv.unlock()


def subcmd_push(rsvars: RestsyncVars, args: argparse.Namespace) -> None:
    if not os.path.isdir(rsvars.data_dir):
        raise RuntimeError(f'Directory {rsvars.data_dir} not found')

    ensure_consistent_data_state(rsvars.data_dir, rsvars.state_file)

    print('Locking restic repo')
    rsvars.rinv.lock()
    try:
        if not args.force:
            print('Ensuring that a pull is not needed')
            if check_need_pull(rsvars.rinv, rsvars.data_dir,
                               state_read(rsvars.state_file, True)):
                raise RuntimeError('Cannot push: need-pull is true')

        rsvars.rinv.restic('backup -v --skip-if-unchanged .',
                           add_popen_kwargs={'cwd': rsvars.data_dir})

        state_write(rsvars.state_file, {
            'latest-snapshot-id': rsvars.rinv.get_latest_snapshot_id()})
    finally:
        print('Unlocking restic repo')
        rsvars.rinv.unlock()


def subcmd_repl(rsvars: RestsyncVars, args: argparse.Namespace) -> None:
    try:
        # Even if not used directly, importing the "readline" module enables
        # arrow-key navigation, input history, and basic line editing for
        # "input()" prompts on Unix-like systems
        import readline
    except ImportError:
        pass

    parser = get_argumentparser(prog='restsync', repl=True)

    def run_repl_argv(repl_argv: list[str]):
        if repl_argv[0] == 'help':
            repl_argv = ['--help']

        repl_args = parser.parse_args(repl_argv)
        repl_args.func(rsvars, repl_args)

    try:
        while True:
            try:
                repl_argv = shlex.split(input('restsync> '))

                if len(repl_argv) == 0:
                    continue

                if repl_argv[0] in ('exit', 'quit'):
                    break

                run_repl_argv(repl_argv)
            except EOFError:  # The user hit CTRL+D
                break
            except KeyboardInterrupt:  # The user hit CTRL+C
                pass
            except SystemExit:
                # Note: the SystemExit error is raised by argparse on parse
                # errors. We need to catch it to prevent exiting the REPL
                pass
            except (RuntimeError, ValueError) as e:
                print(e, file=sys.stderr)
            except subprocess.CalledProcessError:
                pass
            except BaseException:
                traceback.print_exc()
    finally:
        if len(args.run_at_exit) > 0:
            run_repl_argv(args.run_at_exit)


def subcmd_bash(rsvars: RestsyncVars, args: argparse.Namespace) -> None:
    subprocess.check_call(['bash'] + args.args)

################################################################################


def get_argumentparser(prog: str | None = None,
                       repl: bool = False) -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(prog=prog, description='Restsync')

    if not repl:
        parser.add_argument('-u', '--sftp-url', type=str, required=True,
                            help='SFTP URL')
        parser.add_argument('-m', '--ssh-mux', action='store_true',
                            help='Enable SSH multiplexing')
        parser.add_argument('-d', '--data-dir', type=str, required=True,
                            help='Path of the local data directory')
        parser.add_argument('-s', '--state-file', type=str, required=True,
                            help='Path of the local state file')

    subparsers = parser.add_subparsers(metavar='SUBCMD', required=True)

    subparser = subparsers.add_parser('restic', help='Run a restic command')
    subparser.add_argument('args', metavar='ARGS', type=str, nargs='*',
                           help='Command arguments')
    subparser.set_defaults(func=subcmd_restic)

    subparser = subparsers.add_parser('init', help='Initialize the remote '
                                      'restic repository')
    subparser.set_defaults(func=subcmd_init)

    subparser = subparsers.add_parser('resolve', help='Resolve a special '
                                      'snapshot ID')
    subparser.add_argument('snapshot_id', metavar='SNAPSHOT_ID', type=str,
                           help='Special snapshot ID to be resolved. Examples: '
                           'state-latest, latest')
    subparser.set_defaults(func=subcmd_resolve)

    subparser = subparsers.add_parser('tree', help='Build the CSV tree of the '
                                      'local data directory or a remote '
                                      'restic snapshot')
    subparser.add_argument('snapshot_id', metavar='SNAPSHOT_ID', type=str,
                           help='Snapshot ID (will be resolved according to '
                           'the "resolve" subcmd), or "local" for the local '
                           'data directory')
    subparser.set_defaults(func=subcmd_tree)

    subparser = subparsers.add_parser('diff', help='Compare two CSV trees')
    subparser.add_argument('id_a', metavar='ID_A', type=str,
                           help='First snapshot ID (will be resolved '
                           'according to the "resolve" subcmd), or "local" '
                           'for the local data directory')
    subparser.add_argument('id_b', metavar='ID_B', type=str,
                           help='Second snapshot ID (will be resolved '
                           'according to the "resolve" subcmd), or "local" '
                           'for the local data directory')
    subparser.set_defaults(func=subcmd_diff)

    subparser = subparsers.add_parser('need', help='Check if a pull and/or '
                                      'push is needed')
    subparser.add_argument('mode', metavar='MODE', type=str,
                           nargs='?', default='all',
                           help='Check mode. It can be "pull", "push", or '
                           '"all" to check both (default: %(default)s)')
    subparser.set_defaults(func=subcmd_need)

    subparser = subparsers.add_parser('pull', help='Pull remote changes')
    subparser.add_argument('-f', '--force', action='store_true',
                           help='Forcefully overwrite any local changes')
    subparser.set_defaults(func=subcmd_pull)

    subparser = subparsers.add_parser('push', help='Push local changes')
    subparser.add_argument('-f', '--force', action='store_true',
                           help='Forcefully overwrite any remote changes')
    subparser.set_defaults(func=subcmd_push)

    if repl:
        subparser = subparsers.add_parser('bash', help='Start a Bash shell '
                                          'as a subprocess')
        subparser.add_argument('args', metavar='ARGS', type=str, nargs='*',
                               help='Bash command arguments')
        subparser.set_defaults(func=subcmd_bash)

        subparser = subparsers.add_parser('exit', aliases=['quit'],
                                          help='Exit REPL')
    else:
        subparser = subparsers.add_parser('repl', help='Start a REPL')
        subparser.add_argument('-e', '--run-at-exit', type=str, nargs='*',
                               default=[], help='Run command at exit')
        subparser.set_defaults(func=subcmd_repl)

    return parser


################################################################################

def main(argv: list[str] = None) -> int:
    if argv is None:
        argv = sys.argv

    parser = get_argumentparser()

    args = parser.parse_args(argv[1:])

    ############################################################################

    pswretr = PasswordRetriever('RESTSYNC_PSW', 'RESTSYNC_PSW_CMD',
                                'RESTSYNC_PSW_FILE', True)

    sftp_details: SFTPDetails = SFTPDetails.parse(args.sftp_url, False)

    with ExitStack() as stack:
        ssh_cmd = os.getenv('RESTSYNC_SSH_CMD', 'ssh')
        sftp_cmd = os.getenv('RESTSYNC_SFTP_CMD', 'sftp')
        restic_cmd = os.getenv('RESTSYNC_RESTIC_CMD', 'restic')

        if args.ssh_mux:
            ctl_path = '~/.ssh/cm-restsync-%C'

            stack.enter_context(ssh_mux(shlex.split(ssh_cmd) +
                                        ['-oServerAliveInterval=30'] +
                                        sftp_details.ssh_args, ctl_path))

            ssh_cmd += f' -S{ctl_path}'
            sftp_cmd += f' -oControlPath={ctl_path}'

        rinv = ResticInvoker(sftp_details, pswretr.get,
                             ssh_cmd=ssh_cmd, sftp_cmd=sftp_cmd,
                             restic_cmd=restic_cmd)

        rsvars = RestsyncVars(rinv, args.data_dir, args.state_file)

        try:
            args.func(rsvars, args)
        except (RuntimeError, ValueError) as e:
            print(e, file=sys.stderr)
            return 1
        except subprocess.CalledProcessError as e:
            return e.returncode

    return 0


if __name__ == '__main__':
    sys.exit(main())
