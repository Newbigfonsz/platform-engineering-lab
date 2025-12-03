#!/bin/bash
# Quick VM creation script

VMID=$1
NAME=$2
CORES=${3:-2}
MEMORY=${4:-2048}
DISK=${5:-32}
STORAGE=${6:-tank-vmstore}

ssh root@192.168.1.210 "qm clone 9000 $VMID --name $NAME --full && \
  qm set $VMID --cores $CORES --memory $MEMORY && \
  qm resize $VMID scsi0 +${DISK}G && \
  qm start $VMID"

echo "VM $VMID ($NAME) created and started!"
