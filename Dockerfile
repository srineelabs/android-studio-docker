FROM ubuntu:22.04

LABEL Simon Egli <docker_android_studio_860dd6@egli.online>

ARG USER=android

RUN dpkg --add-architecture i386
RUN apt-get update && apt-get install -y \
        build-essential git neovim wget unzip sudo \
        libc6:i386 libncurses5:i386 libstdc++6:i386 lib32z1 libbz2-1.0:i386 \
        libxrender1 libxtst6 libxi6 libfreetype6 libxft2 xz-utils vim\
        qemu qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils libnotify4 libglu1 libqt5widgets5 openjdk-17-jdk xvfb \
        && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN groupadd -g 1000 -r $USER
RUN useradd -u 1000 -g 1000 --create-home -r $USER
RUN adduser $USER libvirt
RUN adduser $USER kvm
#Change password
RUN echo "$USER:$USER" | chpasswd
#Make sudo passwordless
RUN echo "${USER} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/90-$USER
RUN usermod -aG sudo $USER
RUN usermod -aG plugdev $USER
RUN mkdir -p /androidstudio-data
VOLUME /androidstudio-data
RUN chown $USER:$USER /androidstudio-data

RUN mkdir -p /studio-data/Android/Sdk && \
    chown -R $USER:$USER /studio-data/Android


RUN mkdir -p /studio-data/profile/android && \
    chown -R $USER:$USER /studio-data/profile

COPY provisioning/docker_entrypoint.sh /usr/local/bin/docker_entrypoint.sh
COPY provisioning/ndkTests.sh /usr/local/bin/ndkTests.sh
RUN chmod +x /usr/local/bin/*
COPY provisioning/51-android.rules /etc/udev/rules.d/51-android.rules

USER $USER

WORKDIR /home/$USER

#Install Flutter
#ARG FLUTTER_URL=https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.13.6-stable.tar.xz
#ARG FLUTTER_VERSION=3.13.6

#RUN wget "$FLUTTER_URL" -O flutter.tar.xz
#RUN tar -xvf flutter.tar.xz
#RUN rm flutter.tar.xz

#Android Studio
ARG ANDROID_STUDIO_URL=https://redirector.gvt1.com/edgedl/android/studio/ide-zips/2024.2.1.11/android-studio-2024.2.1.11-linux.tar.gz
ARG ANDROID_STUDIO_VERSION=2024.2.1.11

RUN wget "$ANDROID_STUDIO_URL" -O android-studio.tar.gz
RUN tar xzvf android-studio.tar.gz
RUN rm android-studio.tar.gz

RUN wget https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip
RUN unzip commandlinetools-linux-11076708_latest.zip
RUN rm commandlinetools-linux-11076708_latest.zip
RUN mv cmdline-tools /home/$USER/android-studio
RUN /home/$USER/android-studio/cmdline-tools/bin/sdkmanager "platform-tools" "platforms;android-35" "build-tools;35.0.0" "cmdline-tools;latest" "system-images;android-35;default;x86_64" "system-images;android-35;google_apis;x86_64" "system-images;android-35;google_apis_playstore;x86_64" "emulator" "extras;android;m2repository" "extras;google;m2repository"  --sdk_root=/home/$USER/android-studio/cmdline-tools

RUN ln -s /studio-data/profile/AndroidStudio$ANDROID_STUDIO_VERSION .AndroidStudio$ANDROID_STUDIO_VERSION
RUN ln -s /studio-data/Android Android
RUN ln -s /studio-data/profile/android .android
RUN ln -s /studio-data/profile/java .java
RUN ln -s /studio-data/profile/gradle .gradle
ENV ANDROID_EMULATOR_USE_SYSTEM_LIBS=1
COPY android-studio-config.xml .android

WORKDIR /home/$USER

ENTRYPOINT [ "/usr/local/bin/docker_entrypoint.sh" ]
