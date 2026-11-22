#!/bin/sh
# Copyright 2026 Travis Grammer
# SPDX-License-Identifier: Apache-2.0
set -e

# Ensure the git user's .ssh directory exists with correct permissions.
mkdir -p /home/git/.ssh
chmod 700 /home/git/.ssh
chown git:git /home/git/.ssh

# Create authorized_keys if missing. When it exists it may be a read-only
# bind mount (see docker-compose.yml), so only touch/chmod/chown the file we
# create ourselves.
if [ ! -f /home/git/.ssh/authorized_keys ]; then
    touch /home/git/.ssh/authorized_keys
    chmod 600 /home/git/.ssh/authorized_keys
    chown git:git /home/git/.ssh/authorized_keys
fi

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

# Ensure repo home tree is owned by git. Best effort: authorized_keys may be
# a read-only bind mount whose ownership cannot be changed.
chown -R git:git /home/git || true

# sshd does not pass its own environment to user sessions, so translate the
# auto-create knobs into sshd SetEnv directives. Use a single SetEnv line:
# on this OpenSSH build only one SetEnv directive survives config parsing.
setenv_args=
[ -n "${GIT_AUTO_CREATE_MIN_DEPTH:-}" ] && setenv_args="$setenv_args GIT_AUTO_CREATE_MIN_DEPTH=$GIT_AUTO_CREATE_MIN_DEPTH"
[ -n "${GIT_AUTO_CREATE_MAX_DEPTH:-}" ] && setenv_args="$setenv_args GIT_AUTO_CREATE_MAX_DEPTH=$GIT_AUTO_CREATE_MAX_DEPTH"
[ -n "${GIT_SHELL:-}" ] && setenv_args="$setenv_args GIT_SHELL=$GIT_SHELL"
if [ -n "$setenv_args" ]; then
    sed -i '/^SetEnv /d' /etc/ssh/sshd_config
    echo "SetEnv$setenv_args" >> /etc/ssh/sshd_config
fi

exec /usr/sbin/sshd -D -e
