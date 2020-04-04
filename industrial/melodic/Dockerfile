FROM bitbots/bitbots-base:melodic

ENV NVIDIA_VISIBLE_DEVICES \
    ${NVIDIA_VISIBLE_DEVICES:-all}

ENV NVIDIA_DRIVER_CAPABILITIES \
    ${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics

RUN apt update -qq \
    && sudo apt install -y -qq software-properties-common \
    && sudo apt install -y -qq curl figlet \
    && sudo apt install -y -qq nmap

RUN sudo apt-get install python-rosdep \
    && sudo rm -rf /etc/ros/rosdep/sources.list.d/* \
    && sudo rosdep init -q \
    && rosdep update -q \
    && sudo apt install -y -qq python-rosinstall python-rosinstall-generator build-essential\
    && sudo pip install catkin_pkg empy

ENV ROBOT=youbot-brsu-4
ENV ROBOT_ENV=brsu-c025

COPY industrial/melodic/install_pkg_script.sh /melodic/install_pkg_script.sh
RUN chmod +x /melodic/install_pkg_script.sh && /melodic/install_pkg_script.sh
ARG UNAME=melodic_user
ARG UID=1000
ARG GID=1000
RUN groupadd -g $GID -o $UNAME
RUN useradd -m -u $UID -g $GID -o -s /bin/bash $UNAME \
    && adduser $UNAME sudo \
    && echo "$UNAME ALL=(ALL:ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/$UNAME
USER $UNAME