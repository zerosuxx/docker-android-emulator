# docker-android-emulator

## Build
```shell
$ docker-compose build
```

## Usage
```shell
$ docker-compose up # use only `/dev/kvm` device from host machine
$ docker-compose exec app bash -c "adb shell screencap -p /sdcard/screenshot.png && adb pull /sdcard/screenshot.png /app/screenshot.png"
```