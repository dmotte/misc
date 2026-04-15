<?php

// Src: https://github.com/dmotte/misc/tree/main/snippets
function diemsg(string $msg, int $response_code = 500): never
{
    http_response_code($response_code);
    die($msg . PHP_EOL);
}

function is_alnum_3(string $x): bool
{
    return preg_match('/\A[0-9A-Za-z\._-]+\z/', $x) === 1;
}

function ensure_value_ok(string $name, string $value, callable $callback): void
{
    if (!$callback($value)) diemsg('Invalid ' . $name . ' value');
}

////////////////////////////////////////////////////////////////////////////////

header('Content-Type: text/plain');

if (PHP_SAPI === 'cli')
    $data = getopt('', [
        'language:',
        'country:',
        'locale:',
        'keymap:',

        'hostname:',

        'username:',
        'userfullname:',
        'password:',

        'timezone:',

        'disk:',
        'luks:',

        'tasksel:',
        'pkgs:',
        'popcon:',

        'sshd-port:',
        'sudo-nopasswd:',
        'ssh-authkeys:',
    ]);
else $data = $_SERVER['REQUEST_METHOD'] === 'POST' ? $_POST : $_GET;

$data['language'] ??= 'en';
ensure_value_ok('language', $data['language'], 'is_alnum_3');
$data['country'] ??= 'US';
ensure_value_ok('country', $data['country'], 'is_alnum_3');
$data['locale'] ??= 'C';
ensure_value_ok('locale', $data['locale'], 'is_alnum_3');
$data['keymap'] ??= 'us';
ensure_value_ok('keymap', $data['keymap'], 'is_alnum_3');

if (!isset($data['hostname'])) diemsg('Missing hostname');
ensure_value_ok('hostname', $data['hostname'], 'is_alnum_3');

$data['username'] ??= 'mainuser';
ensure_value_ok('username', $data['username'], 'is_alnum_3');
$data['userfullname'] ??= $data['username'];
ensure_value_ok('userfullname', $data['userfullname'], 'is_alnum_3');
$data['password'] ??= '';
ensure_value_ok(
    'password',
    $data['password'],
    fn($x) => preg_match('/\A[ -~]*\z/', $x) === 1,
);

$data['timezone'] ??= 'UTC';
ensure_value_ok(
    'timezone',
    $data['timezone'],
    fn($x) => preg_match('/\A[0-9A-Za-z\/_-]+\z/', $x) === 1,
);

if (!isset($data['disk'])) diemsg('Missing disk');
ensure_value_ok(
    'disk',
    $data['disk'],
    fn($x) => preg_match('/\A[0-9A-Za-z\/_-]+\z/', $x) === 1,
);
$data['luks'] = isset($data['luks']) && $data['luks'] === 'true';

$data['tasksel'] ??= '';
ensure_value_ok(
    'tasksel',
    $data['tasksel'],
    fn($x) => preg_match('/\A[0-9A-Za-z,-]*\z/', $x) === 1,
);
$data['tasksel'] = $data['tasksel'] === ''
    ? []
    : explode(',', $data['tasksel']);
$data['pkgs'] ??= '';
ensure_value_ok(
    'pkgs',
    $data['pkgs'],
    fn($x) => preg_match('/\A[0-9A-Za-z,-]*\z/', $x) === 1,
);
$data['pkgs'] = $data['pkgs'] === '' ? [] : explode(',', $data['pkgs']);
$data['popcon'] = isset($data['popcon']) && $data['popcon'] === 'true';

$data['sshd-port'] ??= '';
ensure_value_ok(
    'sshd-port',
    $data['sshd-port'],
    fn($x) => preg_match('/\A[0-9]*\z/', $x) === 1,
);
$data['sshd-port'] = $data['sshd-port'] === '' ? -1 : (int)$data['sshd-port'];
$data['sudo-nopasswd'] = isset($data['sudo-nopasswd'])
    && $data['sudo-nopasswd'] === 'true';
$data['ssh-authkeys'] ??= '';
ensure_value_ok(
    'ssh-authkeys',
    $data['ssh-authkeys'],
    fn($x) => preg_match('/\A[0-9A-Za-z +,\/=_-]*\z/', $x) === 1,
);
$data['ssh-authkeys'] = $data['ssh-authkeys'] === ''
    ? []
    : explode(',', $data['ssh-authkeys']);

////////////////////////////////////////////////////////////////////////////////

echo 'd-i debian-installer/language string ', $data['language'], PHP_EOL;
echo 'd-i debian-installer/country string ', $data['country'], PHP_EOL;
echo 'd-i debian-installer/locale string ', $data['locale'], PHP_EOL;
echo 'd-i keyboard-configuration/xkb-keymap select ', $data['keymap'], PHP_EOL;
echo PHP_EOL;

// This is needed to restart netcfg, otherwise the "netcfg/*" values are
// all ignored when preseeding via network. See
// https://unix.stackexchange.com/questions/106614/preseed-cfg-ignoring-hostname-setting/342179#comment737438_342179
echo 'd-i preseed/early_command string kill-all-dhcp; netcfg', PHP_EOL;
echo 'd-i netcfg/choose_interface select auto', PHP_EOL;
echo PHP_EOL;

echo 'd-i netcfg/get_hostname string ', $data['hostname'], PHP_EOL;
echo 'd-i netcfg/get_domain string unassigned-domain', PHP_EOL;
echo 'd-i netcfg/hostname string ', $data['hostname'], PHP_EOL;
echo PHP_EOL;

echo 'd-i passwd/root-login boolean false', PHP_EOL;
echo 'd-i passwd/user-fullname string ', $data['userfullname'], PHP_EOL;
echo 'd-i passwd/username string ', $data['username'], PHP_EOL;
// If not specified, the password is asked interactively during the installation
if ($data['password'] !== '') {
    echo 'd-i passwd/user-password password ', $data['password'], PHP_EOL;
    echo 'd-i passwd/user-password-again password ', $data['password'], PHP_EOL;
}
echo PHP_EOL;

echo 'd-i clock-setup/utc boolean true', PHP_EOL;
echo 'd-i time/zone string ', $data['timezone'], PHP_EOL;
echo PHP_EOL;

echo 'd-i partman-auto/init_automatically_partition select ',
'Guided - use entire disk', PHP_EOL;
echo 'd-i partman-auto/disk string ', $data['disk'], PHP_EOL;
if ($data['luks']) {
    echo 'd-i partman-auto/method string crypto', PHP_EOL;
    echo 'd-i partman-lvm/confirm boolean true', PHP_EOL;
    echo 'd-i partman-lvm/confirm_nooverwrite boolean true', PHP_EOL;
} else
    echo 'd-i partman-auto/method string regular', PHP_EOL;
echo 'd-i partman-auto/choose_recipe select atomic', PHP_EOL;
echo 'd-i partman-partitioning/confirm_write_new_label boolean true', PHP_EOL;
echo 'd-i partman/choose_partition select finish', PHP_EOL;
echo 'd-i partman/confirm boolean true', PHP_EOL;
echo 'd-i partman/confirm_nooverwrite boolean true', PHP_EOL;
if ($data['luks'])
    echo 'd-i partman-auto-crypto/erase_disks boolean false', PHP_EOL;
echo PHP_EOL;

if (count($data['tasksel']) === 0)
    echo 'tasksel tasksel/first multiselect', PHP_EOL;
else
    echo 'tasksel tasksel/first multiselect ',
    implode(', ', $data['tasksel']), PHP_EOL;
if (count($data['pkgs']) !== 0)
    echo 'd-i pkgsel/include string ', implode(' ', $data['pkgs']), PHP_EOL;
echo 'popularity-contest popularity-contest/participate boolean ',
$data['popcon'] ? 'true' : 'false', PHP_EOL;
echo PHP_EOL;

echo 'd-i grub-installer/only_debian boolean true', PHP_EOL;
echo 'd-i grub-installer/bootdev string default', PHP_EOL;
echo PHP_EOL;

echo 'd-i finish-install/reboot_in_progress note', PHP_EOL;
// Once the installation is finished, shut down the machine (don't restart)
echo 'd-i debian-installer/exit/poweroff boolean true', PHP_EOL;

if (
    $data['sshd-port'] > 0 ||
    $data['sudo-nopasswd'] ||
    count($data['ssh-authkeys']) !== 0
) {
    echo PHP_EOL;
    echo 'd-i preseed/late_command string in-target bash -ec \'\\', PHP_EOL;

    if ($data['sshd-port'] > 0)
        echo '    sed -Ei "s/^#?Port[ \t].*$/Port ', $data['sshd-port'],
        '/" /etc/ssh/sshd_config; \\', PHP_EOL;

    if ($data['sudo-nopasswd']) {
        echo '    install -Tvm440 <(echo "', $data['username'],
        ' ALL=(ALL) NOPASSWD: ALL") \\', PHP_EOL;
        echo '        /etc/sudoers.d/', $data['username'], '-nopassword; \\',
        PHP_EOL;
    }

    if (count($data['ssh-authkeys']) !== 0) {
        echo '    install -o', $data['username'], ' -g', $data['username'],
        ' -dvm700 ~', $data['username'], '/.ssh; \\', PHP_EOL;
        echo '    install -o', $data['username'], ' -g', $data['username'],
        ' -Tvm600 /dev/null \\', PHP_EOL;
        echo '        ~', $data['username'], '/.ssh/authorized_keys; \\',
        PHP_EOL;

        foreach ($data['ssh-authkeys'] as $key)
            echo '    echo "', $key, '" >> ~', $data['username'],
            '/.ssh/authorized_keys; \\', PHP_EOL;
    }

    echo '\'', PHP_EOL;
}
