FROM smebberson/alpine-base

# Add files
ADD root /

RUN \
    apk upgrade --update && \
    apk add alpine-sdk ttf-dejavu fontconfig-dev subversion && \
    # apk add --update --repository http://alpine.gliderlabs.com/alpine/edge/main ffmpeg && \

    # fv = ffmpeg video
    addgroup fv && \
    adduser -D -G fv fv && \

    addgroup build && \
    adduser -D -s /bin/sh -G build build && \
    addgroup build abuild && \
    echo "build ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    mkdir -p /var/cache/distfiles && \
    chmod a+w /var/cache/distfiles && \

    su build -c "cd /tmp && \
        abuild-keygen -a -i -n -q && \

        svn export https://github.com/alpinelinux/aports/trunk/main/ffmpeg && \
        cd ffmpeg && \
        sed -i 's/--enable-libopus/--enable-libopus --enable-libfreetype --enable-libfontconfig/g' APKBUILD && \
        abuild unpack && \
        abuild prepare && \
        abuild -r" && \

    apk add --allow-untrusted /home/build/packages/tmp/x86_64/ffmpeg-3.3.4-r0.apk && \
    apk add --allow-untrusted /home/build/packages/tmp/x86_64/ffmpeg-libs-3.3.4-r0.apk && \

    rm -rf /tmp/* && \
    rm -rf /home/build/* && \
    rm -rf /var/cache/distfile && \
    deluser build && \

    # cleanup
    apk del alpine-sdk fontconfig-dev subversion && \
    rm -rf /var/cache/apk/*
