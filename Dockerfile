FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Multi-arch support block for Wine32
RUN dpkg --add-architecture i386

# 🛠️ ZORIN OS OFFICIAL REPOSITORIES ADD KARNA (यह इसे असली Zorin बनाएगा)
RUN apt-get update && apt-get install -y --no-install-recommends software-properties-common gnupg2 && \
    add-apt-repository -y ppa:zorinos/stable && \
    add-apt-repository -y ppa:zorinos/patches && \
    add-apt-repository -y ppa:zorinos/apps && \
    add-apt-repository -y ppa:mozillateam/ppa && \
    printf 'Package: firefox*\nPin: release o=LP-PPA-mozillateam\nPin-Priority: 1001\n' > /etc/apt/preferences.d/mozilla-firefox

# Zorin OS के कोर डेस्कटॉप पैकेजेस और लुक मैनेजर इंस्टॉल करना
RUN apt-get update && apt-get install -y --no-install-recommends \
    xrdp \
    xorgxrdp \
    zorin-desktop-session \
    zorin-appearance \
    zorin-desktop-themes \
    zorin-icon-themes \
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

# Xwrapper कॉन्फ़िगरेशन
RUN echo "allowed_users=anybody" > /etc/X11/Xwrapper.config && \
    echo "needs_root_rights=no" >> /etc/X11/Xwrapper.config

# D-Bus के लिए machine-id जनरेट करना
RUN mkdir -p /var/run/dbus && dbus-uuidgen > /var/lib/dbus/machine-id

# XRDP ऑप्टिमाइज़ेशन (कम रैम और बिना GPU के स्मूथ चलाने के लिए)
RUN sed -i 's/crypt_level=high/crypt_level=low/' /etc/xrdp/xrdp.ini && \
    sed -i 's/security_layer=negotiate/security_layer=rdp/' /etc/xrdp/xrdp.ini && \
    sed -i 's/max_bpp=32/max_bpp=24/' /etc/xrdp/xrdp.ini

# ---- 🛠️ FORCE ZORIN OS SESSION RUN ---- #
RUN echo "gnome-session" > /etc/skel/.xsession && \
    printf 'export XDG_CURRENT_DESKTOP=Zorin:GNOME\nexport XDG_SESSION_TYPE=x11\nexport XDG_SESSION_DESKTOP=zorin\nexec gnome-session --session=zorin\n' > /etc/skel/.xsessionrc

RUN echo "gnome-session" > /home/ubuntu/.xsession && \
    printf 'export XDG_CURRENT_DESKTOP=Zorin:GNOME\nexport XDG_SESSION_TYPE=x11\nexport XDG_SESSION_DESKTOP=zorin\nexec gnome-session --session=zorin\n' > /home/ubuntu/.xsessionrc && \
    chown -R ubuntu:ubuntu /home/ubuntu

RUN adduser xrdp ssl-cert

COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 3389

CMD ["/start.sh"]
