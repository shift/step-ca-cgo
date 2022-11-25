# Introduction

This project aims to allow for easily provisioning a certificate authority
on a Raspberry Pi 4 with keys stores on a permanently attached YubiKey.

## Upstream Components

This makes use of the following upstream projects:

 * [Step-CA](https://github.com/smallstep/certificates).
 * [Raspberry Pi 4 UEFI Firmware (forked to enable 8GiB RAM+DeviceTree)](https://github.com/shift/rpi4-uefi/).
 * [Fedora CoreOS](https://getfedora.org/en/coreos).
 * [Podman](https://podman.io/).

## Prerequisites

 * 2x YubiKey with [PIV capabilities](https://developers.yubico.com/PIV/Introduction/Certificate_slots.html) (YubiKey NEO, or YubiKey 4/5)
   1. Root CA pair which can be used for signing Intermediate Certificates.
   2. Root CA certificate and Intermediate CA certificate and private key.
 * 1x Raspberry Pi 4, any RAM size should suffice.
 * SD-card or USB storage for Raspberry Pi.
 * USB storage for Root CA to be held offline in a secure location.
 * Installed [Raspberry Pi Imager (rpi-imager)](https://www.raspberrypi.com/software/).

## Setup steps

### Raspberry Pi 4 Bootloader

Fedora CoreOS is installed via UEFI so please [ensure your bootloader is up to date](https://pimylifeup.com/raspberry-pi-bootloader/#using-the-raspberry-pi-imager) before continuing.

### Yubikey Setup

These steps should be done on an air gapped machine.

You will need 2 Yubikeys. One for your root certificate and key pair, and
another for your intermediate certificate used to issue certificates used
on end devices.

This is _HIGHLY RECOMMENDED_, please don't complain to me if you compromise
your root key or lose them.

### Generate Root and Intermedia Certificate Authorities

```bash
mkdir /tmp/stepca
STEPPATH=/tmp/stepca
step ca init --pki
```
Use the generated files in the next section.

### Key Slots

Root CA YubiKey
| Slot | Key                              |
|------|----------------------------------|
| 9a   | Root Certificate and Key         |


Intermedia CA YubiKey
| Slot | Key                              |
|------|----------------------------------|
| 9a   | Root Certificate                 |
| 9c   | Intermediate Certificate and Key |

With your root ca key plugged in run:
```bash
ykman piv keys import 9a ${STEPPATH}/secrets/root_ca_key
ykman piv certificates import 9a ${STEPPATH}/certs/root_ca.crt
```

This stores your private key and certificate on your token.

With the Yubikey which will reside in your issuing CA run the following:
```bash
ykman piv certificates import 9a ${STEPPATH}/certs/root_ca.crt
ykman piv certificates import 9c ${STEPPATH}/certs/intermediate_ca.crt
ykman piv keys import 9c ${STEPPATH}/secrets/intermediate_ca_key
```

When the container starts up, it connects to the YubiKey and extracts the
root and intermediate certificates and writes them to disk where step-ca
references them.

### Flashing

Visit the [releases page](https://github.com/shift/step-ca-cgo/releases/latest) and download the latest Step-CA-FCOS-RaspberryPi4.img.xz, extract the archive and flash with Raspberry Pi Imager.

**BEFORE YOU ATTEMPT BOOT READ THE CONFIGURATION SECTION**

### Configuration

#### ca.json

This file is located on the boot(,or second) partition of the storage device. 
This is the default ca.json for running via a YubiKey.

The most important parts of the configuration are the kms section, and
key being set too `yubikey:slot-id=9c`.

The root and intermediate certificates are extracted from the YubiKey on first
boot.

#### YubiKey PIN

Please update the `ca.json` file on the partition labelled `boot` (second
partition) and update the kms.pin to match that of your YubiKey. The default
shipped PIN of `123456` is configured by default.

#### Wireless / WLAN / Wi-Fi

Please mount the partition labelled `boot` (second partition).
Copy wifi.txt.example to wifi.txt and update the contents to match your access
point credentials.

**PLEASE NOTE** Fedora CoreOS doesn't ship with the firmware and software
required to make the wireless chip in the Raspberry Pi 4 work out of the box.
When this file is detected, on first boot it will install the required firmware
and the additional wifi package for NetworkManager. This can take around an
hour if your connection is slow.

## Prior Art

 * [Build a Tiny Certificate Authority For Your Homelab](https://smallstep.com/blog/build-a-tiny-ca-with-raspberry-pi-yubikey/).

