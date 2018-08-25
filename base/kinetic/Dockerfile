FROM ros:kinetic

RUN apt update -qq && \
    apt upgrade -y -qq && \
    apt install -y python-catkin-tools \
    python-wstools \
    python-catkin-lint \
    vim \
    && rm -rf /var/lib/apt/lists/*
