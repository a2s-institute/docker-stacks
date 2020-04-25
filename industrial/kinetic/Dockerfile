FROM bitbots/bitbots-base:kinetic

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

WORKDIR /kinetic

RUN wstool init --shallow src \
    && wstool merge -t src https://raw.githubusercontent.com/b-it-bots/mas_industrial_robotics/kinetic/repository.rosinstall \
    && wstool update -t src \
    && rosdep update -q \
    && sudo apt-get update \
    && rosdep install --from-paths src --ignore-src --rosdistro=kinetic --skip-keys rosplan_demos -y \
    && rm -rf src

# OpenCV installation
RUN wget https://github.com/opencv/opencv/archive/3.4.10.zip \
&& unzip 3.4.10.zip \
&& mkdir /opencv-3.4.10/cmake_binary \
&& cd /opencv-3.4.10/cmake_binary \
&& cmake -DWITH_QT=OFF \
        -DWITH_OPENGL=ON \
        -DFORCE_VTK=OFF \
        -DWITH_TBB=ON \
        -DWITH_GDAL=ON \
        -DWITH_XINE=ON \
        -DBUILD_EXAMPLES=OFF \
        -DENABLE_PRECOMPILED_HEADERS=OFF .. \
&& make install \
&& rm /3.4.10.zip \
&& rm -r /opencv-3.4.10

ENV ROBOT=youbot-brsu-4
ENV ROBOT_ENV=brsu-c025

ARG UNAME=kinetic_user
ARG UID=1000
ARG GID=1000
RUN groupadd -g $GID -o $UNAME
RUN useradd -m -u $UID -g $GID -o -s /bin/bash $UNAME \
    && adduser $UNAME sudo \
    && echo "$UNAME ALL=(ALL:ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/$UNAME
USER $UNAME