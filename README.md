# docker-git-remote

A minimal, headless SSH git remote container based on [`alpine/git`][docker-alpine-git], helpful for self-hosting repositories.

Published to [GHCR][ghcr] as [`ghcr.io/travis-g/git`][ghcr-pkg] for `linux/amd64` and `linux/arm64`.

| Tag          | Meaning                                     |
| ------------ | ------------------------------------------- |
| `latest`     | Latest commit on `main`                     |
| `1.2.3`      | Exact release (from tag `v1.2.3`)           |
| `1.2` / `1`  | Rolling major/minor of the latest release   |
| `sha-<short>`| Exact commit                                |

## Setup

1. Add your public key to `authorized_keys` next to `docker-compose.yml`.
2. Start the container — pull the published image:

   ```sh
   docker compose pull
   docker compose up -d
   ```

   or build it yourself:

   ```sh
   docker compose up -d --build
   ```

   Without compose:

   ```sh
   docker run -d --name git-remote \
     -p 2222:22 \
     -v git-data:/home/git \
     -v "$PWD/authorized_keys":/home/git/.ssh/authorized_keys:ro \
     ghcr.io/travis-g/git:latest
   ```

3. On the client, use the remote. The first push creates the repository:

   ```sh
   git remote add origin git@<host>:<user>/<repo>.git
   git push -u origin main
   git clone git@<host>:<user>/<repo>.git
   ```

   Pushing creates the bare repository (`git init --bare`) automatically: no `docker exec` needed.

   `ssh://`-style URLs work too (handy when the host port is not 22, as in the compose example above):

   ```sh
   git remote add origin ssh://git@<host>:2222/<user>/<repo>.git
   ```

## Notes

- The `<user>` in the URL is a directory under `/home/git`, not a system account; only the `git` system user exists. There is no per-namespace isolation or user management.
- `git-shell` is the login shell, so interactive SSH is limited to git operations, and SSH is public-key only (no password login).
- All keys in `authorized_keys` have equal access: every key can read and write every repository. There are no per-user permissions; to revoke a key, remove its line from `authorized_keys`.
- Repositories are created automatically on the first `git push` (`git-receive-pack`) to a missing path. Fetching or cloning a missing repository does not create one. Existing paths are never overwritten.
- Auto-create paths default to `<user>/<repo>.git` (2 components, counting `<repo>.git`). Override with `GIT_AUTO_CREATE_MIN_DEPTH` / `GIT_AUTO_CREATE_MAX_DEPTH` in `docker-compose.yml`. Out-of-range pushes are rejected.
- `GIT_SHELL` can override the delegated shell (default `/usr/bin/git-shell`) for future functionality. These variables are forwarded into SSH sessions via `SetEnv` in `sshd_config` (see `entrypoint.sh`).
- Host SSH keys and repositories are persisted in the `git-data` Docker volume; deleting the volume changes the server identity and causes clients to warn about `REMOTE HOST IDENTIFICATION HAS CHANGED`.

## License

Licensed under Apache-2.0; built on [`alpine/git`][docker-alpine-git], also Apache-2.0. See `LICENSE` and `NOTICE`.

[docker-alpine-git]: https://hub.docker.com/r/alpine/git
[ghcr]: https://ghcr.io
[ghcr-pkg]: https://github.com/travis-g/git/pkgs/container/git
