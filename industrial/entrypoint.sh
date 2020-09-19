#!/bin/bash

# Add the user to video group for HW acceleration (only Intel cards supported)
sudo usermod -aG video robocup

# Load the default ROS entrypoint
source "/opt/ros/$ROS_DISTRO/setup.bash"
source $HOME/${ROS_DISTRO}/devel/setup.bash

bash
