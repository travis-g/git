# docker-git-remote

A minimal, headless SSH git remote container based on [`alpine/git`][docker-alpine-git], helpful for self-hosting repositories.

## Setup

1. Add your public key to `authorized_keys` next to `docker-compose.yml`.
2. Start the container:

   ```sh
   docker compose up -d --build
   ```

3. On the client, use the remote. The first push creates the repository:

   ```sh
   git remote add origin git@<host>:<user>/<repo>.git
   git push -u origin main
   git clone git@<host>:<user>/<repo>.git
   ```

   Pushing creates the bare repository (`git init --bare`) automatically: no `docker exec` needed.

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
