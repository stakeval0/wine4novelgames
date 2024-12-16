FROM ubuntu:latest
ARG USERNAME=docker
ENV HOME=/home/${USERNAME}
RUN apt-get update && apt-get upgrade -y &&\
    apt-get install -y\
    apt-utils curl wget\
    # xserver-xorg \
    x11-apps locales fonts-migmix
RUN dpkg --add-architecture i386 && \
    apt-get update && apt-get install -y \
        wine winetricks
RUN bash -c "apt-get install -y \
        gstreamer1.0-{plugins-{bad,base,good,ugly},libav,pulseaudio}:i386 \
        pulseaudio ffmpeg \
        fonts-{takao,mona,monapo} \
        xvfb winbind \
        "
RUN id -u 1000 >/dev/null && userdel -r $(getent passwd | awk -F: '$3 == 1000 {print $1}')
#RUN useradd -m ${USERNAME} && echo "${USERNAME}:Wine@s4ndb0x" | chpasswd && usermod -aG sudo ${USERNAME}
RUN useradd -m ${USERNAME}
RUN usermod --uid 1000 ${USERNAME} &&\
    groupmod --gid 1000 ${USERNAME}
RUN localedef -f UTF-8 -i ja_JP ja_JP.UTF-8
ENV LANG="ja_JP.UTF-8" \
    LANGUAGE="ja_JP:ja" \
    LC_ALL="ja_JP.UTF-8"
USER ${USERNAME}
ENV WINEARCH=win32
#RUN winetricks -q cjkfonts fakejapanese_ipamona dxvk directx9 &&\
RUN winetricks -q cjkfonts fakejapanese_ipamona d3dx9 d3dx10 d3dx11_43 &&\
    winetricks settings sound=pulse
RUN before=$(stat -c '%Y' ${HOME}/.wine/user.reg) &&\
    wine reg add "HKCU\Software\Wine\X11 Driver" /v UseXRandR /t REG_SZ /d N /f && \
    wine reg add "HKCU\Software\Wine\X11 Driver" /v UseXVidMode /t REG_SZ /d N /f && \
    while [ $(stat -c '%Y' ${HOME}/.wine/user.reg) = $before ]; do sleep 1; done
#RUN xvfb-run winetricks -q windowscodecs wmp9
RUN xvfb-run winetricks -q wmp10
WORKDIR ${HOME}
CMD ["/bin/bash"]
