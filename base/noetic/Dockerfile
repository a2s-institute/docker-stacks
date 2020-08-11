FROM ros:noetic

RUN apt update -qq && \
    apt upgrade -y -qq && \
    apt install vim \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install --no-cache-dir catkin-tools && \
    pip3 install --no-cache-dir catkin-lint && \
    pip3 install --no-cache-dir git+https://github.com/vcstools/wstool.git@master
