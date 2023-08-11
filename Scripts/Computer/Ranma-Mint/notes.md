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
