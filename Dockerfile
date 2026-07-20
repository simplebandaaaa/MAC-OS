FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Multi-arch support block for Wine32
RUN dpkg --add-architecture i386

# Firefox के लिए Mozilla PPA जोड़ना
RUN apt-get update && apt-get install -y --no-install-recommends software-properties-common gnupg2 && \
    add-apt-repository -y ppa:mozillateam/ppa && \
    printf 'Package: firefox*\nPin: release o=LP-PPA-mozillateam\nPin-Priority: 1001\n' > /etc/apt/preferences.d/mozilla-firefox

# सिस्टम अपडेट और Linux Mint का मुख्य 'Cinnamon' डेस्कटॉप इंस्टॉल करना
RUN apt-get update && apt-get install -y --no-install-recommends \
    xrdp \
    xorgxrdp \
    cinnamon-desktop-environment \
    cinnamon-screensaver \
    gnome-terminal \
    xorg \
    dbus-x11 \
    dbus-user-session \
    sudo \
    curl \
    wget \
    nano \
    net-tools \
    ssl-cert \
    polkitd \
    wine \
    wine32:i386 \
    firefox && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# ---- 🛠️ USER SETUP ---- #
RUN mkdir -p /home/ubuntu && \
    usermod -d /home/ubuntu -m ubuntu && \
    echo "ubuntu:ubuntu" | chpasswd && \
    usermod -aG sudo ubuntu && \
    echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Xwrapper कॉन्फ़िगरेशन (ताकि Cinnamon बिना GPU के Xorg पर रेंडर हो सके)
RUN echo "allowed_users=anybody" > /etc/X11/Xwrapper.config && \
    echo "needs_root_rights=no" >> /etc/X11/Xwrapper.config

# D-Bus के लिए machine-id जनरेट करना
RUN mkdir -p /var/run/dbus && dbus-uuidgen > /var/lib/dbus/machine-id

# XRDP ऑप्टिमाइज़ेशन
RUN sed -i 's/crypt_level=high/crypt_level=low/' /etc/xrdp/xrdp.ini && \
    sed -i 's/security_layer=negotiate/security_layer=rdp/' /etc/xrdp/xrdp.ini && \
    sed -i 's/max_bpp=32/max_bpp=24/' /etc/xrdp/xrdp.ini

# ---- 🛠️ CINNAMON (LINUX MINT) FORCE FIX ---- #
# XRDP को मजबूर करना कि वह सिर्फ और सिर्फ Linux Mint का Cinnamon सेशन लोड करे
RUN echo "cinnamon-session" > /etc/skel/.xsession && \
    printf 'export XDG_CURRENT_DESKTOP=X-Cinnamon\nexport XDG_SESSION_TYPE=x11\nexport XDG_SESSION_DESKTOP=cinnamon\nexec cinnamon-session\n' > /etc/skel/.xsessionrc

RUN echo "cinnamon-session" > /home/ubuntu/.xsession && \
    printf 'export XDG_CURRENT_DESKTOP=X-Cinnamon\nexport XDG_SESSION_TYPE=x11\nexport XDG_SESSION_DESKTOP=cinnamon\nexec cinnamon-session\n' > /home/ubuntu/.xsessionrc && \
    chown -R ubuntu:ubuntu /home/ubuntu

RUN adduser xrdp ssl-cert

COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 3389

CMD ["/start.sh"]
