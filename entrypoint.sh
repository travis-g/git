#!/bin/sh
# Copyright 2026 Travis Grammer
# SPDX-License-Identifier: Apache-2.0
set -e

# Ensure the git user's .ssh directory exists with correct permissions.
mkdir -p /home/git/.ssh
chmod 700 /home/git/.ssh
chown git:git /home/git/.ssh

# Create authorized_keys if missing.
if [ ! -f /home/git/.ssh/authorized_keys ]; then
    touch /home/git/.ssh/authorized_keys
fi
chmod 600 /home/git/.ssh/authorized_keys
chown git:git /home/git/.ssh/authorized_keys

# Generate host keys if they do not exist.
for key_type in rsa ecdsa ed25519; do
    key_file="/home/git/.ssh/ssh_host_${key_type}_key"
    if [ ! -f "$key_file" ]; then
        case "$key_type" in
            rsa) ssh-keygen -t rsa -b 4096 -f "$key_file" -N '' ;;
            ecdsa) ssh-keygen -t ecdsa -f "$key_file" -N '' ;;
            ed25519) ssh-keygen -t ed25519 -f "$key_file" -N '' ;;
        esac
        chown git:git "$key_file" "$key_file.pub"
    fi
    chmod 600 "$key_file"
done

# Ensure repo home tree is owned by git.
chown -R git:git /home/git

exec /usr/sbin/sshd -D -e
