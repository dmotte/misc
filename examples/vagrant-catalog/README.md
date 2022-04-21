# vagrant-catalog

In this example we'll first build a **Vagrant box** (`mybox`) and then use it as a **base box** for another VM (`myvm`) using a **Vagrant catalog**.

First of all, if it's not your first time doing this, do a little cleanup:

```bash
cd mybox

vagrant destroy -f
rm package.box
```

Then, without leaving the `mybox` directory, you can **build** the base box:

```bash
vagrant up --provision
vagrant package # Creates the package.box file
vagrant destroy -f
```

Now, to be able to use your base box, you have to customize the `mybox.json` (the **catalog**) file. In particular you have to put in the right values for:

- box **version**
- absolute **URL** of the `package.box` file
- **checksum** of the `package.box` file

To **test** if your base box works, try to bring up `myvm`:

```bash
cd ../myvm

vagrant destroy -f # Cleanup if needed
vagrant box update # Make sure your box version is up to date
vagrant up
```
