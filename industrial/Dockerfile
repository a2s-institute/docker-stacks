ARG ROS_DISTRO

FROM bitbots/bitbots-base:$ROS_DISTRO

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
    unzip \
    gcc-multilib \
    g++-multilib

RUN sudo rm -rf /etc/ros/rosdep/sources.list.d/* \
    && sudo rosdep init -q \
    && rosdep update -q \
    && sudo apt install -y -qq python-rosinstall python-rosinstall-generator build-essential \
    && sudo pip install catkin_pkg empy

# install dependencies
RUN apt-get update
RUN apt-get install -y libopencv-dev ros-$ROS_DISTRO-vision-opencv && \
    yasm libjpeg-dev libavcodec-dev libavformat-dev libswscale-dev && \
    libdc1394-22-dev libv4l-dev python-dev python-numpy libtbb-dev && \
    libqt4-dev libgtk2.0-dev libmp3lame-dev libopencore-amrnb-dev && \
    libopencore-amrwb-dev libtheora-dev libvorbis-dev libxvidcore-dev && \
    x264 v4l-utils pkg-config
RUN apt-get install -y curl build-essential checkinstall cmake

WORKDIR /$ROS_DISTRO

RUN wstool init --shallow src \
    && wstool merge -t src https://raw.githubusercontent.com/b-it-bots/mas_industrial_robotics/$ROS_DISTRO/repository.rosinstall \
    && wstool update -t src \
    && git clone -b $ROS_DISTRO https://github.com/b-it-bots/mas_industrial_robotics.git src/mas_industrial_robotics \
    && rosdep update -q \
    && sudo apt-get update \
    && rosdep install --from-paths src --ignore-src --rosdistro=$ROS_DISTRO --skip-keys rosplan_demos -y \
    && rm -rf src

# Install mesa libary for intel graphic
RUN \
  apt-get update && \
  apt-get -y install libgl1-mesa-glx libgl1-mesa-dri && \
  rm -rf /var/lib/apt/lists/*

ENV ROBOT=youbot-brsu-4
ENV ROBOT_ENV=brsu-c025

ARG UNAME=${ROS_DISTRO}_user
ARG UID=1000
ARG GID=1000
RUN groupadd -g $GID -o $UNAME
RUN useradd -m -u $UID -g $GID -o -s /bin/bash $UNAME \
    && adduser $UNAME sudo \
    && echo "$UNAME ALL=(ALL:ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/$UNAME
USER $UNAME
