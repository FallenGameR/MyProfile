# Notes

## Init

timedatectl set-local-rtc 1 --adjust-system-clock
install vscode, firacode, pwsh
install psprofile

## USB

```ps1
sudo cat /sys/bus/usb/devices/9-1.1.1.1/product
lsusb # Bus 009 Device 012: ID 0424:4064 Microchip Technology, Inc. (formerly SMSC) Ultra Fast Media Reader
echo '9-1.1.1.1' | sudo tee /sys/bus/usb/drivers/usb/unbind
```

```txt
fallengamer@Ranma-Mint:/sys/bus/usb/devices$ grep -l 009/012 /sys/bus/usb/devices/*/uevent
fallengamer@Ranma-Mint:/sys/bus/usb/devices$ grep -l 009 /sys/bus/usb/devices/*/uevent
/sys/bus/usb/devices/9-1.1.1.1/uevent
/sys/bus/usb/devices/9-1.1.1/uevent
/sys/bus/usb/devices/9-1.1/uevent
/sys/bus/usb/devices/9-1.3.2/uevent
/sys/bus/usb/devices/9-1.3.3/uevent
/sys/bus/usb/devices/9-1.3/uevent
/sys/bus/usb/devices/9-1/uevent
/sys/bus/usb/devices/usb9/uevent
fallengamer@Ranma-Mint:/sys/bus/usb/devices$ rg 009
No files were searched, which means ripgrep probably applied a filter you didn't expect.
Running with --debug will show why files are being skipped.
```

## How to resolve USB device

System Reports/System Information will list something like this:

```log
  Hub-11: 9-0:1 info: Hi-speed hub with single TT ports: 1 rev: 2.0 speed: 480 Mb/s
    chip-ID: 1d6b:0002
  Hub-12: 9-1:2 info: Genesys Logic Hub ports: 4 rev: 2.0 speed: 480 Mb/s chip-ID: 05e3:0608
  Hub-13: 9-1.1:10 info: Microchip (formerly SMSC) USB 2.0 Hub ports: 4 rev: 2.0 speed: 480 Mb/s
    chip-ID: 0424:2514
  Hub-14: 9-1.1.1:11 info: Microchip (formerly SMSC) USB 2.0 Hub ports: 2 rev: 2.0
    speed: 480 Mb/s chip-ID: 0424:2640
  Device-1: 9-1.1.1.1:13 info: Microchip (formerly SMSC) Ultra Fast Media Reader
    type: Mass Storage driver: usb-storage rev: 2.0 speed: 480 Mb/s chip-ID: 0424:4064
  Device-2: 9-1.1.2:12 info: Microsoft LifeCam Cinema type: Video,Audio
    driver: snd-usb-audio,uvcvideo rev: 2.0 speed: 480 Mb/s chip-ID: 045e:075d
```
