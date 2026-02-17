ARG BASE_IMAGE=quay.io/a2s-institute/base-gpu-notebook:cuda12-ubuntu22.04

FROM $BASE_IMAGE

LABEL maintainer="A2S Institute <robotics@h-brs.de>"

USER root

# ---- Locale setup (UTF-8) ----
RUN set -eux; \
    locale; \
    locale-gen en_US en_US.UTF-8; \
    update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8; \
    export LANG=en_US.UTF-8; \
    locale

ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    gnupg \
    lsb-release \
    locales \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

RUN add-apt-repository universe && \
    apt -y update

# ---- Install ROS 2 apt source ----
RUN set -eux; \
    ROS_APT_SOURCE_VERSION=$(curl -s https://api.github.com/repos/ros-infrastructure/ros-apt-source/releases/latest \
        | grep -F "tag_name" \
        | awk -F\" '{print $4}'); \
    UBUNTU_CODENAME=$(. /etc/os-release && echo ${UBUNTU_CODENAME:-${VERSION_CODENAME}}); \
    curl -L -o /tmp/ros2-apt-source.deb \
        "https://github.com/ros-infrastructure/ros-apt-source/releases/download/${ROS_APT_SOURCE_VERSION}/ros2-apt-source_${ROS_APT_SOURCE_VERSION}.${UBUNTU_CODENAME}_all.deb"; \
    dpkg -i /tmp/ros2-apt-source.deb; \
    rm /tmp/ros2-apt-source.deb; \
    apt update -y

RUN apt update -y && \
    apt install ros-humble-desktop -y && \
    echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc && \
    rm -rf /var/lib/apt/lists/*

USER $NB_USER
