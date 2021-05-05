#!/usr/bin/env bash

set -e

cd page
yarn run build
mv build ../docs