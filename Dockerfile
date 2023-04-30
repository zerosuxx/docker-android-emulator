FROM adoptopenjdk/openjdk8:alpine

RUN apk update && \
    apk upgrade && \
    apk add --no-cache \
        bash \
        git \
        unzip \
        curl \
        libvirt-daemon \
        qemu-img \
        qemu-system-x86_64 \
        dbus \
        polkit \
        virt-manager \
        tzdata && \
    rm -rf /var/lib/apt/lists/* /var/cache/apk/* /tmp/* /var/tmp/*

# config timezone
ENV TZ=Europe/Budapest
RUN cp "/usr/share/zoneinfo/${TZ}" /etc/localtime

# android pre-installed sdk tools/libs
ARG ANDROID_VERSION="android-30"
ARG ANDROID_MODULE="default"
ARG ANDROID_ARCH="x86_64"
ARG ANDROID_EMULATOR_PACKAGE_X86="system-images;${ANDROID_VERSION};${ANDROID_MODULE};${ANDROID_ARCH}"
ARG ANDROID_PLATFORM_VERSION="platforms;${ANDROID_VERSION}"
ARG ANDROID_SDK_VERSION="sdk-tools-linux-4333796.zip"
ARG ANDROID_SDK_PACKAGES_EXTRA=""
ARG ANDROID_SDK_PACKAGES="${ANDROID_EMULATOR_PACKAGE_X86} ${ANDROID_PLATFORM_VERSION} platform-tools emulator ${ANDROID_SDK_PACKAGES_EXTRA}"

# create app user with groups
RUN adduser -D app -u 1000 -s /bin/bash && \
    addgroup app kvm   
USER app

# gradle caching
RUN mkdir -p ~/.cache
ENV GRADLE_USER_HOME="$HOME/.cache"
VOLUME $GRADLE_USER_HOME

# install android sdk
RUN curl -o /tmp/android-sdk.zip https://dl.google.com/android/repository/${ANDROID_SDK_VERSION} && \
    unzip -d ~/android /tmp/android-sdk.zip && \
    rm -rf /tmp/android-sdk.zip
ENV ANDROID_HOME="$HOME/android"
ENV PATH "$PATH:$ANDROID_HOME/emulator:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools"

# sdkmanager
RUN mkdir ~/.android && \ 
    touch ~/.android/repositories.cfg
RUN yes Y | sdkmanager --licenses
RUN yes Y | sdkmanager --verbose --no_https ${ANDROID_SDK_PACKAGES}

# avdmanager
ENV EMULATOR_NAME_X86="android_x86"
ENV LD_LIBRARY_PATH "$ANDROID_HOME/emulator/lib64:$ANDROID_HOME/emulator/lib64/qt/lib"
RUN echo "no" | avdmanager --verbose create avd --force --name "${EMULATOR_NAME_X86}" --device "pixel" --package "${ANDROID_EMULATOR_PACKAGE_X86}"

COPY --chmod=0755 start-emulator.sh /usr/local/bin/start-emulator

SHELL ["bash", "-c"]

CMD ["start-emulator"]
