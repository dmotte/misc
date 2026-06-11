# win-export-drivers

In **Windows**, drivers are usually stored in the following directories:

- `C:\Windows\System32\Drivers`
- `C:\Windows\System32\DriverStore`
- `C:\Windows\System32\DRVSTORE` (not always present)

In particular, on Windows 10 / 11, in `C:\Windows\System32\DriverStore\FileRepository` you should see a subdirectory for each installed driver. Each subdir should contain an `.inf` file that describes the driver and the device(s) it's designed for.

If you have _Git Bash_ installed and you want to find the driver(s) for a specific device by its **hardware ID**, you can use a command like this:

```bash
grep -IRi --include='*.inf' --color DEV_1C03 /c/Windows/System32/DriverStore
```

However, that might not find anything, because the `.inf` files often use **UTF-16 encoding**, which might be unsupported by `grep`. To overcome this limitation, you can change your command like this:

```bash
grep -IRai --include='*.inf' --color D.E.V._.1.C.0.3 /c/Windows/System32/DriverStore
```

Once you find the drivers you're looking for, you can copy them to a USB stick pendrive, insert it into another PC and install the driver(s) there, by selecting the pendrive location when Windows asks for a directory to "find the drivers automatically".

## Links

- [How to export installed device driver on Windows 7 for later use - Super User](https://superuser.com/questions/1196061/how-to-export-installed-device-driver-on-windows-7-for-later-use)
- [Backing up and Restoring Windows Drivers - gHacks Tech News](https://www.ghacks.net/2011/09/26/backing-up-and-restoring-windows-drivers/)
- [backup - How do I go about backing up/saving installed device drivers in Windows - Super User](https://superuser.com/questions/29704/how-do-i-go-about-backing-up-saving-installed-device-drivers-in-windows)
