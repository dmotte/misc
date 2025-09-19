# android-fastboot-twrp

:warning: **Disclaimer**: this guide is intended for **educational purposes** only. Modifying your device using `fastboot` or _TWRP_ involves risks such as **data loss**, **bricking your device**, or **voiding the warranty**. I am not responsible for any possible damage caused to your phone.

Usual **boot key combinations**:

- **Fastboot** mode: hold volume down + plug in the USB cable to the PC
- **Recovery** mode: hold volume up + power button

If you want to boot into [**TWRP**](https://twrp.me/) without installing it, first boot the phone into **fastboot mode** and then, from the PC, run these commands:

```bash
fastboot reboot bootloader
fastboot boot twrp-3.6.2_9-0-tissot.img
```

To **flash** TWRP (partition name may be different):

```bash
fastboot flash recovery twrp-3.6.2_9-0-tissot.img
```

Some devices have **two boot partitions** (slot A and slot B). You can switch between them via:

```bash
fastboot set_active a
fastboot set_active b
```

To erase a partition:

```bash
fastboot erase userdata
```

## Links

- [Install LineageOS on tissot - LineageOS Wiki](https://wiki.lineageos.org/devices/tissot/install)
- [BACKUP and RESTORE FULL ROM using TWRP Recovery - September 2021 - YouTube](https://www.youtube.com/watch?v=EKeONaQB_Zo)
- [Can I change the Boot Slot from Fastboot with a command - XDA Forums](https://forum.xda-developers.com/t/can-i-change-the-boot-slot-from-fastboot-with-a-command.3977207/)
