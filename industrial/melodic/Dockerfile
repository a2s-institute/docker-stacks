FROM bitbots/bitbots-base:melodic

ARG DEBIAN_FRONTEND=noninteractive

ENV NVIDIA_VISIBLE_DEVICES \
    ${NVIDIA_VISIBLE_DEVICES:-all}

ENV NVIDIA_DRIVER_CAPABILITIES \
    ${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics

RUN apt update -qq \
    && sudo apt-get install -y -qq software-properties-common \
    curl \
    figlet \
    wget \
    nmap \
    gcc-multilib \
    g++-multilib

RUN sudo rm -rf /etc/ros/rosdep/sources.list.d/* \
    && sudo rosdep init -q \
    && rosdep update -q \
    && sudo apt install -y -qq python-rosinstall python-rosinstall-generator build-essential \
    && sudo pip install catkin_pkg empy

WORKDIR /melodic

RUN wstool init --shallow src \
    && wstool merge -t src https://raw.githubusercontent.com/b-it-bots/mas_industrial_robotics/melodic/repository.rosinstall \
    && wstool update -t src \
    && rosdep update -q \
    && sudo apt-get update \
    && rosdep install --from-paths src --ignore-src --rosdistro=melodic --skip-keys rosplan_demos -y \
    && rm -rf src

ENV ROBOT=youbot-brsu-4
ENV ROBOT_ENV=brsu-c025

ARG UNAME=melodic_user
ARG UID=1000
ARG GID=1000
RUN groupadd -g $GID -o $UNAME
RUN useradd -m -u $UID -g $GID -o -s /bin/bash $UNAME \
    && adduser $UNAME sudo \
    && echo "$UNAME ALL=(ALL:ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/$UNAME
USER $UNAME