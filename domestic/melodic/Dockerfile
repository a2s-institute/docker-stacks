FROM ghcr.io/b-it-bots/docker/bitbots-base:melodic

COPY base.rosinstall /melodic/base.rosinstall

WORKDIR /melodic

RUN wstool init --shallow src && \
    wstool merge -t src base.rosinstall

WORKDIR /melodic/src

RUN wstool update

RUN . /opt/ros/melodic/setup.sh && \
    apt-get update -qq && \
    rosdep update -q && \
    rosdep install --from-paths . -i --rosdistro=melodic -y && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /melodic

RUN catkin config --init && \
    catkin config --extend /opt/ros/melodic && \
    catkin config --install --install-space /opt/ros/mas_stable && \
    rm -rf /melodic/
