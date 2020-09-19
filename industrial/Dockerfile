ARG ROS_DISTRO

FROM bitbots/bitbots-base:$ROS_DISTRO

ARG DEBIAN_FRONTEND=noninteractive

ENV NVIDIA_VISIBLE_DEVICES \
    ${NVIDIA_VISIBLE_DEVICES:-all}

ENV NVIDIA_DRIVER_CAPABILITIES \
    ${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics

RUN apt-get update -qq \
    && sudo apt-get install -y -qq \
      apt-utils \
      software-properties-common \
      curl \
      figlet \
      wget \
      nmap \
      unzip \
      gcc-multilib \
      g++-multilib 

RUN pip install --upgrade pip

RUN sudo rm -rf /etc/ros/rosdep/sources.list.d/* \
    && sudo rosdep init -q \
    && rosdep update -q \
    && sudo apt-get install -y -qq build-essential 

# Install dependencies according to distribution
RUN apt-get update
RUN pip install --no-cache-dir catkin_pkg empy

RUN apt-get install -y libopencv-dev ros-$ROS_DISTRO-vision-opencv \
        yasm libjpeg-dev libavcodec-dev libavformat-dev libswscale-dev \
        libdc1394-22-dev libv4l-dev python-dev python-numpy libtbb-dev \
        qt5-default libgtk2.0-dev libmp3lame-dev libopencore-amrnb-dev \
        libopencore-amrwb-dev libtheora-dev libvorbis-dev libxvidcore-dev \
        x264 v4l-utils pkg-config
RUN apt-get install -y curl build-essential checkinstall cmake

# Install mesa libary for HW acceleration 
# Intel graphic cards
RUN apt-get update &&\
    apt-get install -y \
        libgl1-mesa-glx \
        libgl1-mesa-dri 
  
#RUN rm -rf /var/lib/apt/lists/*

# Some QT-Apps/Gazebo don't show controls without this
ENV QT_X11_NO_MITSHM 1

ARG UNAME=robocup
ARG WSDIR=/home/$UNAME/$ROS_DISTRO
ARG UID=1000
ARG GID=1000
RUN groupadd -g $GID -o $UNAME
RUN useradd -m -s /bin/bash -N -u $UID $UNAME && \
    adduser $UNAME sudo && \
    echo "$UNAME ALL=(ALL:ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/$UNAME && \
    mkdir -p $WSDIR && \
    chown $UNAME:$GID $WSDIR

WORKDIR $WSDIR
USER $UNAME

COPY bashrc /home/$UNAME/.bashrc
COPY bash_profile /home/$UNAME/.bash_profile

USER root
RUN apt-get update --fix-missing

USER $UNAME
RUN wstool init --shallow src \
    && wstool merge -t src https://raw.githubusercontent.com/b-it-bots/mas_industrial_robotics/$ROS_DISTRO/repository.rosinstall \
    && wstool update -t src \
    && git clone -b $ROS_DISTRO https://github.com/b-it-bots/mas_industrial_robotics.git src/mas_industrial_robotics \
    && rosdep update -q \
    && rosdep install --from-paths src --ignore-src --rosdistro=$ROS_DISTRO --skip-keys rosplan_demos -y 

USER root
# Install dependencies (includes perception deps) according to distribution
COPY $ROS_DISTRO-deps-install.sh /tmp/  
RUN chmod u+x /tmp/$ROS_DISTRO-deps-install.sh && bash /tmp/$ROS_DISTRO-deps-install.sh $WSDIR $ROS_DISTRO

WORKDIR $WSDIR/src
#provide directory for external mount
RUN mkdir -p $WSDIR/src/external_mounts && \
    chown $UNAME:$GID $WSDIR/src/external_mounts

USER $UNAME
# use melodic devel instead of kinetic
RUN cd $WSDIR/src/mas_perception_msgs && git checkout a0e8819
# this package is not integrated to mas_industrial_robotics yet
#RUN cd $WSDIR && . /opt/ros/$ROS_DISTRO/setup.sh && catkin build mir_object_recognition

ENV ROBOT=youbot-brsu-4
ENV ROBOT_ENV=brsu-c025

#RUN . $WSDIR/devel/setup.sh
COPY entrypoint.sh /usr/sbin/entrypoint.sh
RUN sudo chmod +x /usr/sbin/entrypoint.sh
ENTRYPOINT /usr/sbin/entrypoint.sh

