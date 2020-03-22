#!/bin/bash
set -e

echo "GPU: ${ENABLE_GPU}"

/opt/fahclient/FAHClient \
    --user="${USER}" \
    --team="${TEAM}" \
    --passkey="${PASSKEY}" \
    --gpu="${ENABLE_GPU}" \
    --smp="${ENABLE_SMP}" \
    --power="${POWER}" \
    --gui-enabled=false \
    "${@}"
