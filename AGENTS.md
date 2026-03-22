# AGENTS Notes

## Repo Layout

- `rtlbs-client`: Vue 2 app using Vue CLI 3 and Vuetify 1.
- `rtlbs-server`: Django 2.0 app with SQLite by default plus Redis-backed caching.

## What I Found

- The client expects an untracked file at `rtlbs-client/src/config.js`.
- `rtlbs-client/src/config.js.sample` shows the only required setting is `API_URL`.
- The backend imports `server.core.*` and `server.apps.*`, so it expects to run from a directory literally named `server`.
- The checked-out folder is named `rtlbs-server`, which is why the compose setup mounts it at `/app/server` inside the container.
- The backend defaults to SQLite (`db.sqlite3`) so Postgres is not required for basic local development.
- Redis is effectively required because `apps/rooms/utils.py` uses `cache.lock(...)` when computing stats.
- Media upload handling shells out to `ffmpeg` for non-MP4 videos, so the backend container includes it.
- `apps/rooms/migrations/0002_datamigration.py` seeds the segment/room reference data during `migrate`.

## Local Run Strategy

- Use the root `compose.yaml`.
- `server` runs Django on `http://localhost:18100`.
- `client` runs the Vue dev server on `http://localhost:8080`.
- `redis` runs on `localhost:6379`.
- `fixtures` is a one-shot init service that runs Django migrations and regenerates `rtlbs-client/src/fixtures.js` before the client starts.
- This top-level directory is the launcher/orchestration project. Keep infra files here rather than modifying either `rtlbs-*` project unless there is a strong reason to do so.
- The compose startup command writes:
  - `rtlbs-server/core/settings_local.py` with Redis wired to the compose service and `API_URL` set to `http://localhost:18100/`
  - `rtlbs-client/vue.config.js` that excludes only `src/fixtures.js` from the ESLint webpack rule
  - `rtlbs-client/src/config.js` with `API_URL` pointing at the local backend
  - `rtlbs-client/src/fixtures.js` by running `python manage.py dump_client_fixtures` inside the server image

## Expected Command

```bash
docker compose up --build
```

## Fixture Generation

- The backend already contains the required Django command at `server.apps.rooms.management.commands.dump_client_fixtures`.
- Compose now runs that command automatically in the `fixtures` init service during startup.
- The client waits for `rtlbs-client/src/fixtures.js` to exist before starting the Vue dev server.
- `migrate` is part of the fixture step because the source tables come from `rooms` migrations, including the seeded segment/room data in `0002_datamigration.py`.
- The generated output matches what the Vue app imports today: `segments`, `segmentsBySlug`, `rooms`, `roomsBySlug`, and `roomsBySegment`.

## Caveats

- I analyzed and codified the setup, but I did not fully execute `docker compose up --build` in this environment because image builds would need network access for package downloads.
- The backend pins very old dependencies: Django 2.0.3 and Python 3.6-era packages. The root-level `Dockerfile.rtlbs-server.dev` intentionally uses `python:3.6-buster` to stay compatible.
- Because Debian Buster is end-of-life, the backend Dockerfile rewrites apt sources to `archive.debian.org` before installing system packages.
- The frontend is also older Vue CLI tooling. `node:16` is a safer baseline than newer Node releases for this stack.
- The generated `fixtures.js` file is very large, so the launcher excludes only that file from the Vue ESLint webpack rule to avoid formatter crashes while preserving linting for the rest of the app.
- If uploads are not part of local testing, the app should still run without exercising the `ffmpeg` path.
- There may still be app-level issues after boot because this is an older codebase, but the compose setup captures the required infrastructure and path assumptions.

## Next Helpful Checks

- Verify `docker compose up --build` on a machine with Docker/network access.
- If the backend boots but the UI is empty, create test users/data with Django management commands such as `python manage.py seed_roomtimes --qty 50`.
- Consider replacing generated startup files with proper env-based settings if we keep modernizing the repo.
