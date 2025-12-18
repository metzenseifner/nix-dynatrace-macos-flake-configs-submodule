#!/usr/bin/env zsh

function runInDocker() {
docker run --platform linux/amd64 k13engineering/archlinux-arm64v8 ls
}
