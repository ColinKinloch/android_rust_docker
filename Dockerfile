FROM debian:9.4-slim

# Deps
RUN apt update \
  && apt upgrade -y \
  && apt install -y \
  curl \
  gcc \
  bsdtar \
  && rm -rf /var/lib/apt/lists/*
  
RUN mkdir -p /opt/android-sdk
RUN mkdir -p /opt/android-ndk

# Android SDK
RUN curl https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip | \
  bsdtar -xvpf- -C /opt/android-sdk

# Android NDK
RUN curl https://dl.google.com/android/repository/android-ndk-r17-linux-x86_64.zip | \
  bsdtar -xvpf- -C /opt/android-ndk

# Rust
ADD https://sh.rustup.rs rustup.sh
RUN chmod +x rustup.sh
RUN ./rustup.sh -y --default-toolchain nightly
ENV PATH=/root/.cargo/bin:$PATH

ENV NDK_HOME="/opt/android-ndk/android-ndk-r17"
ENV ANDROID_NDK=$NDK_HOME
ENV ANDROID_NDK_HOME=$NDK_HOME
ENV ANDROID_NDK_ROOT=$NDK_HOME

ENV ANDROID_SDK_HOME="/opt/android-sdk/tools"
ENV ANDROID_HOME=$ANDROID_SDK_HOME

# Android
RUN rustup target add \
  arm-linux-androideabi \
  armv7-linux-androideabi \
  aarch64-linux-android

ADD cargo /.cargo

RUN mkdir build
WORKDIR build

ENV TC=$NDK_HOME/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin
RUN chmod -R 777 $NDK_HOME/*
ENV PATH=$TC:$PATH

ADD fake-ld.sh /opt/
ADD fake-ld-arm.sh /opt/
ADD fake-ld-armv7.sh /opt/

RUN chmod 777 /opt/fake-ld*

# docker run -eUSER -v "$(pwd)/tester":/build 8c6c21ec7384 rustup
