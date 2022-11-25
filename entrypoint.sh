#!/bin/sh

echo -n "Starting pcscd in the backgound"
/usr/sbin/pcscd
echo "."
if [ $1 == "extract" ];
then
  echo -n "Extracting certificates from Yubikey:"
  echo -n " root_ca.crt"
  /usr/bin/ykman piv certificates export 9a /data/certs/root_ca.crt
  echo -n ". intermediate_ca.crt"
  /usr/bin/ykman piv certificates export 9c /data/certs/intermediate_ca.crt
  echo "."
  echo "Exiting."
  exit 0
fi
exec /ca/bin/step-ca
