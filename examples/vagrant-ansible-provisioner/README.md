# vagrant-ansible-provisioner

This is a usage example of the [`dmotte/dockerbox`](https://app.vagrantup.com/dmotte/boxes/dockerbox) Vagrant box that uses Vagrant's [Ansible Provisioner](https://developer.hashicorp.com/vagrant/docs/provisioning/ansible).

From here on, let's assume you have put this folder in `~/myvm` on your PC.

Now customize the [`Vagrantfile`](Vagrantfile); in particular, you may want to customize the `config.vm.synced_folder` section. For example:

```ruby
config.vm.synced_folder "~/git", "/home/vagrant/git"
```

This means that the `~/git` folder on your PC will be mounted to `/home/vagrant/git` inside the VM.

Then you may want to customize the [`playbook.yml`](playbook.yml) file too; it contains just some examples of what you can do.

From the `~/myvm` directory, run the following command to **bring up your VM**:

```bash
vagrant up
```

You can also add the following **alias** to your `~/.bashrc` file (replacing the script path with the correct one for your case):

```bash
alias myvmssh=~/myvm/myvmssh.sh
```

Open a new shell window. Now you can execute stuff in your VM from any directory within your `~/git` folder, using the `myvmssh` alias command. For example:

```bash
myvmssh docker ps -a
```
