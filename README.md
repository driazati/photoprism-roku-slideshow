# PhotoPrism / RokuTV Slideshow

This is a Roku channel that displays a slideshow of every photo available from a particular PhotoPrism instance.

## Usage

There are only 2 screens, the slideshow and options screen. To go to the options screen, press '*' on your remote. On the first launch you will need to do this to add your PhotoPrism information (e.g. the hostname/IP, username, and password).

## Installation

To install the channel, [enable developer mode](https://developer.roku.com/docs/developer-program/getting-started/developer-setup.md) on your Roku device and run the included `upload.py` script, which will package the channel and send it to your device.

```bash
# Change the --tv-ip, --username, and --password to the values specific for
# your device 
python3 upload.py --tv-ip 192.168.1.100 --username rokudev --password mypassword
```

## Debugging

`upload.py` attaches a telnet session after uploading the channel which shows logs.