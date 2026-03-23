This repo is a dev environment for running strathub.

Ideally it comes up by just running:

```
git clone https://github.com/FoxLisk/strathub-dev.git
git submodule update --init --recursive
docker compose up --build
```

if that doesn't work, holler at me.

The SRC page will not work, because it requires a very long operation to populate the data. Ideally this would be either fixed to not
be insanely slow, or just removed (better IMO but plausibly hard to sell to users). If you really want to test this, you can uncomment the `fetch_runs` line in `compose.yaml`, but I have not yet had the patience to wait that out to tell you how long it will take.