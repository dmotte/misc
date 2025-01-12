# talos-prod-vbox

This guide explains how to set up a **[Talos Linux](https://www.talos.dev/)** (_Kubernetes_) **cluster** using **VirtualBox VMs**, following **production-ready best-practices** as much as possible. Of course, for real production, you shouldn't use _VirtualBox_: this guide serves just as inspiration, and to see what the process looks like.

> **Note**: if you want to quickly spin up a _Talos Linux_ cluster using **Docker containers** instead, just to try it out, you should refer to https://www.talos.dev/v1.9/introduction/quickstart/. It should be as simple as running something like:
>
> ```bash
> talosctl cluster create --controlplanes 3 --workers 3
> ```

This guide is heavily inspired by the official _Talos Linux_ documentation. In particular:

- [Getting Started - Talos Linux](https://www.talos.dev/v1.9/introduction/getting-started/)
- [Production Clusters - Talos Linux](https://www.talos.dev/v1.9/introduction/prodnotes/)
- [ISO - Talos Linux](https://www.talos.dev/v1.9/talos-guides/install/bare-metal-platforms/iso/)

## Goal

The goal of this guide is to create a _Talos Linux_ cluster with **3 control plane nodes** and **3 worker nodes**.

A **VirtualBox NAT Network** will be used for network communication. The control host will be able to access the Talos and Kubernetes APIs via **port forwarding rules**.

| Node            | Type          | Talos API access from host | Kubernetes API access from host |
| --------------- | ------------- | -------------------------- | ------------------------------- |
| `192.168.10.11` | Control plane | `127.0.0.1:5011`           | `127.0.0.1:6011`                |
| `192.168.10.12` | Control plane | `127.0.0.1:5012`           | `127.0.0.1:6012`                |
| `192.168.10.13` | Control plane | `127.0.0.1:5013`           | `127.0.0.1:6013`                |
| `192.168.10.21` | Worker        | `127.0.0.1:5021`           | -                               |
| `192.168.10.22` | Worker        | `127.0.0.1:5022`           | -                               |
| `192.168.10.23` | Worker        | `127.0.0.1:5023`           | -                               |

## Control host tools

First of all, you need to install some utilities on your host. This guide has been tested with:

- **VirtualBox** version **7.1.4**
- **`talosctl`** version **1.9.1**
- **`kubectl`** version **1.32.0**
- **Helm** version **3.16.4** TODO make sure that you really need Helm later in the guide

## VirtualBox NAT Network

Create the **VirtualBox NAT Network** for the nodes. You can use a command similar to the following:

```bash
vboxmanage natnetwork add --netname mynat01 --network 192.168.10.0/24 --enable --dhcp on
```

To create the **port forwarding rules**:

```bash
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

Then you can run the following commands to **create the virtual machines**:

TODO
