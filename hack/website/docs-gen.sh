#!/usr/bin/env bash

set -ex

cd page
yarn run build
rm -rf ../docs
mv build ../docs