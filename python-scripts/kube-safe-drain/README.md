# kube-safe-drain

This script can be used to **safely drain** all the **cordoned nodes** in a _Kubernetes_ cluster, by performing all the necessary **rollout restarts**.

## Usage

> **Important**: this has been tested with **Python 3.11.2** on **Debian 12** (_bookworm_).

First you have to **cordon** all the nodes you want to drain. Example:

```bash
kubectl cordon mynode
```

Then **generate** the list of `rollout restart` commands:

```bash
kubectl get -A node,pod,cj,deploy,ds,job,rs,sts -ojson | python3 main.py
```

**Review** the list and **run** the commands. The rollout restarts **may take some time**, even after the commands have completed the execution.

Finally, **check** that the nodes have been drained successfully. Example:

```bash
kubectl drain --ignore-daemonsets --delete-emptydir-data --dry-run=client mynode
```
