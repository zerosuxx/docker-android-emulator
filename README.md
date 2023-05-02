# docker-android-emulator

[![Docker Image CI](https://github.com/zerosuxx/docker-android-emulator/actions/workflows/deploy.yaml/badge.svg)](https://github.com/zerosuxx/docker-android-emulator/actions/workflows/deploy.yml)
[![Docker Pulls](https://img.shields.io/docker/pulls/zerosuxx/android-emulator)](https://hub.docker.com/r/zerosuxx/android-emulator)

## Build
```shell
$ docker-compose build
```

## Usage
```shell
$ docker-compose up # use only `/dev/kvm` device from host machine
$ docker-compose exec app bash -c "adb shell screencap -p /sdcard/screenshot.png && adb pull /sdcard/screenshot.png /app/screenshot.png"
```