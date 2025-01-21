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

## Control host tools

First of all, you need to install some utilities on your host. This example has been tested with:

- **VirtualBox** version **7.1.4**
- **`talosctl`** version **1.9.1**
- **`kubectl`** version **1.32.0**
- **Helm** version **3.17.0**

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
        -c"$cpus" -m"$mem" -d102400 -i metal-amd64.iso

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

## Storage

To set up **persistent storage** in your cluster, you have the following options.

### Local storage

With a **local storage** solution, each `PersistentVolume` you create (and its data) will be **bound to a specific node**. It's a **simple and lightweight** approach, and often it's just enough.

For example, one such solution is **Rancher Local Path Provisioner**; to set it up, see https://www.talos.dev/v1.9/kubernetes-guides/configuration/local-storage/#local-path-provisioner.

Note that, since you can **choose the directory** on the host (node) in which to save the data, you can also configure it to save to a **partition on a secondary disk**, by leveraging this _Talos Linux_ feature: [`machine.disks[].partitions[]`](https://www.talos.dev/v1.9/reference/configuration/v1alpha1/config/#Config.machine.disks..partitions.)

### Replicated storage

With a **replicated persistent storage** solution, the data of each `PersistentVolume` can be **replicated on many nodes**. This approach is often more **complicated and resource-intensive**.

For example, one such solution is **OpenEBS Replicated PV Mayastor**; to set it up, see https://www.talos.dev/v1.9/kubernetes-guides/configuration/storage/#openebs-mayastor-replicated-storage.

If you choose to set up this solution, please make sure that your cluster satisfies the [**minimum requirements for Mayastor**](https://openebs.io/docs/user-guides/replicated-storage-user-guide/replicated-pv-mayastor/rs-installation#prerequisites).

## Ingress Controller

You can set up the [**Ingress-Nginx Controller**](https://kubernetes.github.io/ingress-nginx/) in your cluster by following this guide: [Ingress-Nginx Quick start](https://kubernetes.github.io/ingress-nginx/deploy/#quick-start). I recomment using **Helm** as the installation method, as it's the most simple and straightforward one.

Since we are working with a **bare-metal Kubernetes cluster**, to actually make _Ingress-Nginx_ available, we need to rely on **`NodePort`s**. Please refer to this section of the official documentation: [Bare-metal Ingress-Nginx over a NodePort Service](https://kubernetes.github.io/ingress-nginx/deploy/baremetal/#over-a-nodeport-service).

I suggest setting the following Helm values, to **make the port numbers constant**:

| Key                                  | Value   |
| ------------------------------------ | ------- |
| `controller.service.nodePorts.http`  | `30080` |
| `controller.service.nodePorts.https` | `30443` |

We can also create an additional **Virtual IP** `192.168.10.20` for worker nodes, using _Talos Linux_'s [Virtual (shared) IP feature](https://www.talos.dev/v1.9/talos-guides/network/vip/). It's the same thing we did for control plane nodes. Example: [link](patch-controlplane-11.yaml#L12).

In the end, you should be able to access the **exposed node ports** like this:

```bash
curl http://192.168.10.20:30080/
curl https://192.168.10.20:30443/ --insecure
```

Remember that, to make them available outside the **VirtualBox NAT Network**, you will have to create **additional port forwardings**, like we did in the [VirtualBox NAT Network](#virtualbox-nat-network) section.

## Next steps

You might want to do some **additional setup**. For example:

- [Ingress Firewall - Talos Linux](https://www.talos.dev/v1.9/talos-guides/network/ingress-firewall/): learn to use Talos Linux Ingress Firewall to limit access to the host services
- [Logging - Talos Linux](https://www.talos.dev/v1.9/talos-guides/configuration/logging/): dealing with Talos Linux logs
- [Deploying Metrics Server - Talos Linux](https://www.talos.dev/v1.9/kubernetes-guides/configuration/deploy-metrics-server/): in this guide you will learn how to set up metrics-server

To set up a custom **CNI** (_Container Network Interface_) (useful for example if you need [Network Policies](https://kubernetes.io/docs/concepts/services-networking/network-policies/)):

- [Network - Talos Linux](https://www.talos.dev/v1.9/kubernetes-guides/network/): managing the Kubernetes cluster networking

To perform **upgrades**:

- [Upgrading Talos Linux - Talos Linux](https://www.talos.dev/v1.9/talos-guides/upgrading-talos/): guide to upgrading a Talos Linux machine
- [Upgrading Kubernetes - Talos Linux](https://www.talos.dev/v1.9/kubernetes-guides/upgrading-kubernetes/): guide on how to upgrade the Kubernetes cluster from Talos Linux
