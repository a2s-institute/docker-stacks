FROM ros:melodic

RUN apt update -qq && \
    apt upgrade -y -qq && \
    apt install -y python-catkin-tools \
    python-wstools \
    python-catkin-lint \
    vim \
    python-pip \
    && rm -rf /var/lib/apt/lists/*
