ARG BASE_IMAGE=quay.io/a2s-institute/base-gpu-notebook:cuda12-ubuntu20.04

FROM $BASE_IMAGE

LABEL maintainer="Mohammad Wasil <e2x@inf.h-brs.de>"

USER root

RUN sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list' && \
    curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add -

RUN apt update -y && \
    apt install ros-noetic-desktop-full -y && \
    echo "source /opt/ros/noetic/setup.bash" >> ~/.bashrc && \
    rm -rf /var/lib/apt/lists/*

USER $NB_USER
