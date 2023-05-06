FROM eclipse-temurin:17-jdk

RUN apt-get update && \
    apt-get install -y \
        git \
        curl \
        libvirt-daemon \
        virt-manager \
        tzdata \
        libarchive-tools \
        nano && \
    apt-get clean autoclean && \
    apt-get autoremove --yes && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/

# config timezone
ENV TZ=Europe/Budapest
RUN cp "/usr/share/zoneinfo/${TZ}" /etc/localtime

# android pre-installed sdk tools/libs
ARG ANDROID_VERSION="android-30"
ARG ANDROID_CMD_TOOLS_VERSION="9477386"
ARG ANDROID_MODULE="default"
ARG ANDROID_ARCH="x86_64"
ARG ANDROID_EMULATOR_PACKAGE_X86="system-images;${ANDROID_VERSION};${ANDROID_MODULE};${ANDROID_ARCH}"
ARG ANDROID_PLATFORM_VERSION="platforms;${ANDROID_VERSION}"
ARG ANDROID_SDK_PACKAGES_EXTRA=""
ARG ANDROID_SDK_PACKAGES="${ANDROID_EMULATOR_PACKAGE_X86} ${ANDROID_PLATFORM_VERSION} platform-tools emulator ${ANDROID_SDK_PACKAGES_EXTRA}"

# create app user with groups
RUN adduser \
    app \
    --disabled-password \
    --uid 1000 \
    --shell /bin/bash && \
    addgroup app kvm  
USER app
ENV HOME="/home/app"

# gradle caching
RUN mkdir -p ~/.cache
ENV GRADLE_USER_HOME="${HOME}/.cache"
VOLUME $GRADLE_USER_HOME

# install android sdk
RUN mkdir -p ~/android/cmdline-tools/tools/bin && \
    curl https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_CMD_TOOLS_VERSION}_latest.zip | bsdtar -xvf- -C ~/android/cmdline-tools/tools --strip-components=1 && \
    chmod -R +x ~/android/cmdline-tools/tools/bin
ENV ANDROID_SDK_ROOT="${HOME}/android"
ENV PATH "${PATH}:${ANDROID_SDK_ROOT}/emulator:${ANDROID_SDK_ROOT}/cmdline-tools/tools/bin:${ANDROID_SDK_ROOT}/platform-tools"

# sdkmanager
RUN mkdir ~/.android && \ 
    touch ~/.android/repositories.cfg && \
    echo "_version.3D32.1.12.0.26coreVersion.3Dqemu2.25202.12.0 = 1683375178" > ~/.android/emu-update-last-check.ini
RUN yes Y | sdkmanager --licenses
RUN yes Y | sdkmanager --verbose --no_https ${ANDROID_SDK_PACKAGES}

# avdmanager
ENV EMULATOR_NAME_X86="android_x86"
ENV LD_LIBRARY_PATH "${ANDROID_SDK_ROOT}/emulator/lib64:${ANDROID_SDK_ROOT}/emulator/lib64/qt/lib"
RUN echo "no" | avdmanager --verbose create avd --force --name "${EMULATOR_NAME_X86}" --device "pixel" --package "${ANDROID_EMULATOR_PACKAGE_X86}"

COPY --chmod=0755 start-emulator.sh /usr/local/bin/start-emulator

CMD ["start-emulator"]
