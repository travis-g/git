# docker-git-remote

A minimal, headless SSH git remote container based on [`alpine/git`][docker-alpine-git], helpful for self-hosting repositories.

## Setup

1. Add your public key to `authorized_keys` next to `docker-compose.yml`.
2. Start the container:

   ```sh
   docker compose up -d --build
   ```

3. Create a bare repository:

   ```sh
   docker exec git-remote mkdir -p /home/git/<user>
   docker exec git-remote git init --bare /home/git/<user>/<repo>.git
   docker exec git-remote chown -R git:git /home/git/<user>
   ```

4. On the client, use the remote:

   ```sh
   git remote add origin git@<host>:<user>/<repo>.git
   git push origin main
   git clone git@<host>:<user>/<repo>.git
   ```

## Notes

- The `<user>` in the URL is a directory under `/home/git`, not a system account; only the `git` system user exists. There is no per-namespace isolation.
- `git-shell` is the login shell, so interactive SSH is limited to git operations, and SSH is public-key only (no password login).
- All keys in `authorized_keys` have equal access: every key can read and write every repository. There are no per-user permissions; to revoke a key, remove its line from `authorized_keys`.
- Repositories are not created automatically on push. You must run `docker exec git-remote git init --bare /home/git/<user>/<repo>.git` first, or the push will fail. There is no API, web UI, or user management.
- Host SSH keys and repositories are persisted in the `git-data` Docker volume; deleting the volume changes the server identity and causes clients to warn about `REMOTE HOST IDENTIFICATION HAS CHANGED`.

## License

Licensed under Apache-2.0; built on [`alpine/git`][docker-alpine-git], also Apache-2.0. See `LICENSE` and `NOTICE`.

[docker-alpine-git]: https://hub.docker.com/r/alpine/git
