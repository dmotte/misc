#!/usr/bin/env python3

import json
import sys


CONTROLLER_KINDS_SKIP = ('CronJob', 'DaemonSet')
CONTROLLER_KINDS_ACCEPT = ('Deployment', 'StatefulSet')


def leaves(tree: dict, key_children: str, key_get: str):
    if len(tree[key_children]) == 0:
        return [tree[key_get]]

    return [
        leave
        for child in tree[key_children]
        for leave in leaves(child, key_children, key_get)
    ]


def res2ref(res: dict):
    '''
    Converts a resource dict into a resource reference, i.e. a dict with only
    namespace, kind and name
    '''
    return {
        'namespace': res['metadata'].get('namespace'),
        'kind': res['kind'],
        'name': res['metadata']['name'],
    }


def resolve_ref(resources: list, ref: dict):
    '''
    Given a resource reference (a dict with namespace, kind and name), scans
    the resources list to find the associated resource
    '''
    matches = [
        r for r in resources
        if r['metadata'].get('namespace') == ref['namespace']
        and r['kind'] == ref['kind']
        and r['metadata']['name'] == ref['name']
    ]
    if len(matches) == 0:
        raise LookupError(f'No resource found for reference {ref}')
    if len(matches) > 1:
        raise LookupError(f'Multiple resources found for reference {ref}')
    return matches[0]


def controllers_tree(resources: list, res: dict):
    '''
    Given a resource dict, recursively builds the tree of all its controllers
    '''
    return {'resource': res, 'controllers': [
        controllers_tree(resources, resolve_ref(resources, {
            'namespace': res['metadata']['namespace'],
            'kind': ownref['kind'],
            'name': ownref['name'],
        }))
        for ownref in res['metadata'].get('ownerReferences', [])
        if ownref['controller']
    ]}


def workloads_to_restart(resources: list,
                         kinds_skip: list | tuple, kinds_accept: list | tuple):
    '''
    Gets the list of the Kubernetes workloads that need to be restarted, i.e.
    the workloads that have at least one pod running on a cordoned node
    '''

    cordoned_nodes_names = [
        r['metadata']['name'] for r in resources
        if r['kind'] == 'Node' and r['spec'].get('unschedulable')
    ]

    if len(cordoned_nodes_names) == 0:
        raise LookupError('There are no cordoned nodes in the cluster')

    workloads = {}

    for node_name in cordoned_nodes_names:
        for pod in (
            r for r in resources
            if r['kind'] == 'Pod' and r['spec']['nodeName'] == node_name
        ):
            for ctrl in leaves(controllers_tree(resources, pod),
                               'controllers', 'resource'):
                ns = ctrl['metadata']['namespace']
                kind = ctrl['kind']
                name = ctrl['metadata']['name']

                if kind in kinds_skip:
                    continue
                if kind not in kinds_accept:
                    raise ValueError(f'Invalid controller kind {kind}')

                id = f'{kind} {ns}/{name}'
                if id not in workloads:
                    workloads[id] = ctrl

    return workloads.values()


def main():
    input = json.load(sys.stdin)

    workloads = workloads_to_restart(
        input['items'], CONTROLLER_KINDS_SKIP, CONTROLLER_KINDS_ACCEPT)

    for workload in workloads:
        wlref = res2ref(workload)
        ns, kind, name = wlref['namespace'], wlref['kind'], wlref['name']
        print(f'kubectl rollout restart -n {ns} {kind} {name}')

    return 0


if __name__ == '__main__':
    sys.exit(main())
