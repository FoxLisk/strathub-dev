This repo is a dev environment for running strathub. Ideally it comes up by just running `docker compose up --build`; if it doesn't, let me know.

The SRC page will not work, because it requires a very long operation to populate the data. Ideally this would be either fixed to not
be insanely slow, or just removed (better IMO but plausibly hard to sell to users). If you really want to test this, you can uncomment the `fetch_runs` line in `compose.yaml`, but I have not yet had the patience to wait that out to tell you how long it will take.