# talos-prod-vbox

This is an example of how to set up a **[Talos Linux](https://www.talos.dev/)** (_Kubernetes_) **cluster** using **VirtualBox VMs**, following **production-ready best-practices** as much as possible. Of course, for real production, you shouldn't use _VirtualBox_: this tutorial serves just as inspiration, and to see what the process looks like.

> **Note**: if you want to quickly spin up a _Talos Linux_ cluster using **Docker containers** instead, just to try it out, you should refer to [Quickstart - Talos Linux](https://www.talos.dev/v1.9/introduction/quickstart/). It should be as simple as running something like:
>
> ```bash
> talosctl cluster create --controlplanes 3 --workers 3
> ```

This example is heavily inspired by the official _Talos Linux_ documentation. In particular:

- [Getting Started - Talos Linux](https://www.talos.dev/v1.9/introduction/getting-started/): a guide to setting up a Talos Linux cluster
- [ISO - Talos Linux](https://www.talos.dev/v1.9/talos-guides/install/bare-metal-platforms/iso/): booting Talos on bare-metal with ISO
- [Production Clusters - Talos Linux](https://www.talos.dev/v1.9/introduction/prodnotes/): recommendations for setting up a Talos Linux cluster in production
- [Static Addressing - Talos Linux](https://www.talos.dev/v1.9/advanced/advanced-networking/#static-addressing), part of the "Advanced Networking" guide

## Overview

The goal of this tutorial is to create a _Talos Linux_ cluster with **3 control plane nodes** and **3 worker nodes**.

A **VirtualBox NAT Network** will be used for network communication. The control host will be able to access the Talos and Kubernetes APIs via **port forwarding rules**.

| IP address      | Type                                          | Talos API access from host | Kubernetes API access from host |
| --------------- | --------------------------------------------- | -------------------------- | ------------------------------- |
| `192.168.10.10` | Virtual IP shared between control plane nodes | -                          | `127.0.0.1:6010`                |
| `192.168.10.11` | Control plane node                            | `127.0.0.1:5011`           | `127.0.0.1:6011`                |
| `192.168.10.12` | Control plane node                            | `127.0.0.1:5012`           | `127.0.0.1:6012`                |
| `192.168.10.13` | Control plane node                            | `127.0.0.1:5013`           | `127.0.0.1:6013`                |
| `192.168.10.21` | Worker node                                   | `127.0.0.1:5021`           | -                               |
| `192.168.10.22` | Worker node                                   | `127.0.0.1:5022`           | -                               |
| `192.168.10.23` | Worker node                                   | `127.0.0.1:5023`           | -                               |

Plus, each node will have an **additional 100 GB disk** for **persistent data**. TODO check if this is feasible. Also, maybe only the worker nodes need the additional disk

## Control host tools

First of all, you need to install some utilities on your host. This example has been tested with:

- **VirtualBox** version **7.1.4**
- **`talosctl`** version **1.9.1**
- **`kubectl`** version **1.32.0**
- **Helm** version **3.16.4** TODO make sure that you really need Helm later in the tutorial

## VirtualBox NAT Network

Create the **VirtualBox NAT Network** for the nodes. You can use a command similar to the following:

```bash
vboxmanage natnetwork add --netname mynat01 --network 192.168.10.0/24 --enable --dhcp on
```

To create the **port forwarding rules**:

```bash
vboxmanage natnetwork modify --netname mynat01 \
    --port-forward-4 "Kubernetes10:tcp:[127.0.0.1]:6010:[192.168.10.10]:6443"
for i in {11..13}; do
    vboxmanage natnetwork modify --netname mynat01 \
        --port-forward-4 "Talos$i:tcp:[127.0.0.1]:50$i:[192.168.10.$i]:50000" \
        --port-forward-4 "Kubernetes$i:tcp:[127.0.0.1]:60$i:[192.168.10.$i]:6443"
done
for i in {21..23}; do
    vboxmanage natnetwork modify --netname mynat01 \
        --port-forward-4 "Talos$i:tcp:[127.0.0.1]:50$i:[192.168.10.$i]:50000"
done
```

## VMs

Download the `metal-amd64.iso` **ISO file** from https://github.com/siderolabs/talos/releases.

Then you can leverage the [`create-vbox-vm-headless.sh`](https://github.com/dmotte/misc/blob/main/scripts/create-vbox-vm-headless.sh) script to **create the virtual machines** (replace `metal-amd64.iso` with the correct path of the ISO file):

```bash
while read -r name cpus mem; do
    ./create-vbox-vm-headless.sh -n"$name" -oLinux_64 \
        -c"$cpus" -m"$mem" -d102400,102400 -i metal-amd64.iso

    vboxmanage modifyvm "$name" --nic1 natnetwork --nat-network1 mynat01
done << 'EOF'
TalosCtrl11   4   2048
TalosCtrl12   4   2048
TalosCtrl13   4   2048
TalosWork21   2   1024
TalosWork22   2   1024
TalosWork23   2   1024
EOF
```

> **Note**: you may also want to adjust some values based on [System Requirements - Talos Linux](https://www.talos.dev/v1.9/introduction/system-requirements/).

## Nodes setup

We are now ready to generate the _Talos Linux_ **cluster configuration** files:

```bash
talosctl gen config mycluster https://192.168.10.10:6443

for i in {11..13}; do
    talosctl machineconfig patch controlplane.yaml -p"@patch-controlplane-$i.yaml" -o "controlplane-$i.yaml"
done
for i in {21..23}; do
    talosctl machineconfig patch worker.yaml -p"@patch-worker-$i.yaml" -o "worker-$i.yaml"
done
```

Now **start** all the VMs.

Once started, change their **network configuration** to make them reachable by the host via the port-forwarding rules created before. In general, you need to set the following:

- DNS Servers: `1.1.1.1 1.0.0.1`
- Interface: `enp0s3`
- Mode: `Static`
- Addresses: `192.168.10.XX/24` (replace `XX` with the proper number for each VM)
- Gateway: `192.168.10.1`

> **Note**: you can access the **network configuration screen** by pressing the `F3` key in the VM.

> **Note**: if the **main network interface name** is different, please remember to change it in the configuration files too.

We should now be ready to **apply the cluster configuration** to the nodes:

```bash
for i in {11..13}; do
    talosctl apply-config -in "127.0.0.1:50$i" -f "controlplane-$i.yaml"
done
for i in {21..23}; do
    talosctl apply-config -in "127.0.0.1:50$i" -f "worker-$i.yaml"
done
```

They should **reboot** automatically. After that, you can **bootstrap the Kubernetes cluster**:

```bash
talosctl --talosconfig=talosconfig bootstrap -e127.0.0.1:5011 -n192.168.10.11
```

**Wait a few minutes** for the _Kubernetes_ cluster to be set up, and then you can **get the `kubeconfig`**:

```bash
talosctl --talosconfig=talosconfig kubeconfig ./kubeconfig -e127.0.0.1:5011 -n192.168.10.11
sed -Ei 's/^(\s+server:\s+https:\/\/).+$/\1127.0.0.1:6010/' kubeconfig

kubectl --kubeconfig=kubeconfig get nodes
```

At this point, even if the _Kubernetes_ cluster is now working, it's a good idea to **detach the ISO disks** from the VMs. If you don't do so, they will throw an error on the next boot saying that "Talos is already installed to disk but booted from another media", "Please reboot from the disk".

To detach the ISOs:

```bash
for i in Talos{Ctrl{11..13},Work{21..23}}; do
    vboxmanage storageattach "$i" --storagectl IDE --port 0 --device 0 --type dvddrive --medium none
done
```

Finally, if you want, you can also **set the endpoints** in your `talosconfig` file, so you won't have to pass the `-e` flag anymore on every `talosctl` invocation:

```bash
talosctl --talosconfig=talosconfig config endpoint 127.0.0.1:50{11,12,13}

talosctl --talosconfig=talosconfig -n192.168.10.11 get disks
```

## Next steps

Now that you have a functional _Kubernetes_ cluster, you might want to do some **additional setup**. For example:

- [Ingress Firewall - Talos Linux](https://www.talos.dev/v1.9/talos-guides/network/ingress-firewall/): learn to use Talos Linux Ingress Firewall to limit access to the host services
- [Logging - Talos Linux](https://www.talos.dev/v1.9/talos-guides/configuration/logging/): dealing with Talos Linux logs
- [Deploying Metrics Server - Talos Linux](https://www.talos.dev/v1.9/kubernetes-guides/configuration/deploy-metrics-server/): in this guide you will learn how to set up metrics-server

To set up **storage**: TODO use the additional 100GB volumes created previously

- [Replicated Local Storage - Talos Linux](https://www.talos.dev/v1.9/kubernetes-guides/configuration/replicated-local-storage-with-openebs/): using local storage with OpenEBS
- [Storage - Talos Linux](https://www.talos.dev/v1.9/kubernetes-guides/configuration/storage/): setting up storage for a Kubernetes cluster

To set up a custom **CNI** (_Container Network Interface_) (useful for example if you need [Network Policies](https://kubernetes.io/docs/concepts/services-networking/network-policies/)):

- [Network - Talos Linux](https://www.talos.dev/v1.9/kubernetes-guides/network/): managing the Kubernetes cluster networking

To perform **upgrades**:

- [Upgrading Talos Linux - Talos Linux](https://www.talos.dev/v1.9/talos-guides/upgrading-talos/): guide to upgrading a Talos Linux machine
- [Upgrading Kubernetes - Talos Linux](https://www.talos.dev/v1.9/kubernetes-guides/upgrading-kubernetes/): guide on how to upgrade the Kubernetes cluster from Talos Linux

TODO maybe add some more stuff
