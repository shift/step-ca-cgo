# Introduction

This project aims to allow for easily provisioning a certificate authority
on a Raspberry Pi 4 with keys stores on a permanently attached YubiKey.

## Yubikey Setup

### Key Slots

| Slot | Key                              |
|------|----------------------------------|
| 9a   | Root Certificate                 |
| 9c   | Intermediate Certificate and Key |

You will need 2 Yubikeys. One for your root certificate and kay pair, and
another for your intermediate certificate used to issue certificates used
on end devices.

This is _HIGHLY RECOMMENDED_, please don't complain to me if you compromise
your root key or lose them.

With your root ca key plugged in run:
```bash
ykman piv keys import 9a secrets/root_ca_key
ykman piv certificates import 9a certs/root_ca.crt
```

This stores your private key and certificate on your token.

With the Yubikey which will reside in your issuing CA run the following:
```bash
ykman piv certificates import 9a certs/root_ca.crt
ykman piv certificates import 9c certs/intermediate_ca.crt
ykman piv keys import 9c secrets/intermediate_ca_key
```

When the container starts up, it connects to the YubiKey and extracts the
root and intermediate certificates and writes them to disk where step-ca
references them.
