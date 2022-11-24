#!/bin/sh

echo "Starting pcscd in the backgound"
/usr/sbin/pcscd
exec /ca/bin/step-ca
