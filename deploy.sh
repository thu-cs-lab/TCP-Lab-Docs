#!/bin/bash

set -e

sleep 1
git fetch
git reset --hard origin/master
poetry install
poetry run zensical build
mkdir -p /srv/deploy/tcp-lab-docs
cp -r site/* /srv/deploy/tcp-lab-docs/
