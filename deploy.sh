#!/bin/bash

set -e

sleep 1
git fetch
git reset --hard origin/master
uv sync
uv run zensical build
mkdir -p /srv/deploy/tcp-lab-docs
cp -r site/* /srv/deploy/tcp-lab-docs/
