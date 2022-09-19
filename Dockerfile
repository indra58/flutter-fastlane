FROM fedora:latest
ENV ANDROID_COMPILE_SDK=29
ENV ANDROID_BUILD_TOOLS=29.0.0
ENV ANDROID_SDK_TOOLS=3859397
ENV FLUTTER_CHANNEL=stable
ENV FLUTTER_VERSION=3.3.2-${FLUTTER_CHANNEL}
# install some needed dependencies
# -y will auto confirm the command
# to keep the container as small as possible, clean all will delete 
# the downloaded dependencies
RUN dnf update -y \
    && dnf install -y wget tar unzip ruby ruby-devel make autoconf automake redhat-rpm-config lcov\
           gcc gcc-c++ libstdc++.i686 java-1.8.0-openjdk-devel xz git mesa-libGL mesa-libGLU rubygems\
    && dnf clean all
ENV JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk
ENV PATH=$PATH:$JAVA_HOME
# Download Android SDK
# echo "y" will auto confirm license agreement
RUN wget --quiet --output-document=android-sdk.zip https://dl.google.com/android/repository/sdk-tools-linux-${ANDROID_SDK_TOOLS}.zip \
    && unzip android-sdk.zip -d /opt/android-sdk-linux/ \
    && echo "y" | /opt/android-sdk-linux/tools/bin/sdkmanager "platforms;android-${ANDROID_COMPILE_SDK}" \
    && echo "y" | /opt/android-sdk-linux/tools/bin/sdkmanager "platform-tools" \
    && echo "y" | /opt/android-sdk-linux/tools/bin/sdkmanager "build-tools;${ANDROID_BUILD_TOOLS}" \
    && echo "y" | /opt/android-sdk-linux/tools/bin/sdkmanager "extras;android;m2repository" \
    && echo "y" | /opt/android-sdk-linux/tools/bin/sdkmanager "extras;google;google_play_services" \
    && echo "y" | /opt/android-sdk-linux/tools/bin/sdkmanager "extras;google;m2repository" \
    && yes | /opt/android-sdk-linux/tools/bin/sdkmanager  --licenses || echo "Failed" \
    && rm android-sdk.zip
    
# make SDK tools available for CI
ENV ANDROID_HOME=/opt/android-sdk-linux
ENV PATH=$PATH:/opt/android-sdk-linux/platform-tools/
# Download Flutter SDK
RUN wget --quiet --output-document=flutter.tar.xz https://storage.googleapis.com/flutter_infra/releases/${FLUTTER_CHANNEL}/linux/flutter_linux_v${FLUTTER_VERSION}.tar.xz \
    && tar xf flutter.tar.xz -C /opt \
    && rm flutter.tar.xz
# make Flutter available for CI
ENV PATH=$PATH:/opt/flutter/bin
# if you want to autoincrease Flutter version number the next three lines are helpful
ENV PATH=$PATH:/opt/flutter/bin/cache/dart-sdk/bin
RUN flutter pub global activate pubspec_version
ENV PATH="$PATH":"/opt/flutter/.pub-cache/bin"
RUN echo "y" | /opt/android-sdk-linux/tools/bin/sdkmanager "emulator" \
    && echo "y" | /opt/android-sdk-linux/tools/bin/sdkmanager "system-images;android-18;google_apis;x86" \
    && echo "y" | /opt/android-sdk-linux/tools/bin/sdkmanager "system-images;android-${ANDROID_COMPILE_SDK};google_apis_playstore;x86"
# install Fastlane
    
RUN gem install fastlane
RUN dnf update -y \
    && dnf install -y pulseaudio-libs mesa-libGL  mesa-libGLES mesa-libEGL \
    && dnf clean all
RUN echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" \
    && echo "Don't forget to change the Flutter version also on the Mac mini if you've changed it here!" \
    && echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"