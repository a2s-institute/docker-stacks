# Docker Image for BitBots Industrial
Docker images are available for **Ubuntu 16.04 based ROS-Kinetic** and **Ubuntu 18.04 based ROS-Melodic** environments with all the necessary ros packages and dependencies already installed. Hence, it is sufficient to clone the MAS industrial robotics repository and perform a hassle free catkin build and launching ROS nodes from within the docker container. <br>

Advantages of using this image over a local build:
* All necessary ROS dependencies and packages come bundled with the image
* Containers can easily be started by using docker compose
* Hassle free catkin build without any environment issues
* No user rights issues when creating/cloning folders from within the container
* ROS nodes and ROS master can be launched from within the container and can also communicate with nodes/clients running outside the container, on the local Ubuntu machine
* Supports GUI rendering for *gazebo* and *rviz*
* The container already has source codes pulled inside and you can run or edit the codes but they are ephermal and will be destroyed when the image is rebuild. 
* If you want your local direcotries to be mounted instead, you can mount them to `external_mounts` under `$HOME/<ROS_DISTRO>/src/external_mounts`.

## 1. Using docker-compose file start-container.yml

* start-container.yml file runs services to spawn up containers based on *bitbots/bitbots-industrial:kinetic-base* and *bitbots/bitbots-industrial:melodic-base* images
* Download the sample start-container.yml file from this repository and modify the following based on your requirements:
  * Accelartor

    To enable graphic accelarators e.g. nvidia, add the following to `start-container.yaml`

    ```
    volumes:
      - /usr/lib32/nvidia-390:/usr/lib32/nvidia-390  # provide locally installed -
      - /usr/lib/nvidia-390:/usr/lib/nvidia-390      # - nvidia driver version
    environment:
      - NVIDIA_VISIBLE_DEVICES=all
      - LD_LIBRARY_PATH=/usr/lib/nvidia-390:/usr/lib32/nvidia-390
    ```
    **NOTE**

    Modify the nvidia-390 with the version of nvidia driver installed in your system


  * $HOME/.rviz:/home/<ros_dist>_user/.rviz is optional. Favorite Rviz configurations which are stored in your local file system will be mounted onto your docker container
  * Configuring `external_mounts`
    
    For example, we want to mount `mas_industrial_robotics` and `mas_perception_msgs` to the container, add the followings under `volume`:

    ```
    volumes:
      - /home/mhwasil/ros_catkin_ws/src/b-it-bots/mas_industrial_robotics:/home/robocup/kinetic/src/external_mounts/mas_industrial_robotics:rw
      - /home/mhwasil/ros_catkin_ws/src/b-it-bots/mas_perception_msgs:/home/robocup/kinetic/src/external_mounts/mas_perception_msgs:rw
    ```

    **NOTE**

    Any file you change inside `mas_industrial_robotics and mas_perception_msgs` reflects the one iside the docker. So you can use you favorite IDE like vscode, atom, etc to work on your project.

  ---

  **NOTE**

  Some packages may have been prebuilt in the container, so you need to clean them first by `catkin clean <package_name>`.

  You should also catkin ignore or remove the packages that have been replaced with the ones from your local PC. For example, ignore  `mas_industrial_robotics` and `mas_perception_msgs`:
  ```
  roscd mas_industrial_robotics
  touch CATKIN_IGNORE

  roscd mas_perception_msgs
  touch CATKIN_IGNORE
  ```

  ---

* Then run the following command from the folder containing the start-container.yml file. This spins up two containers based on the kinetic and melodic bitbots/bitbots-industrial:<ros_dist>-base image
```sh
docker-compose -f industrial/start-container.yml up
```
To just start a single container for either melodic or kinetic, use
```sh
docker-compose -f industrial/start-container.yml up ros_<ros_dist>_container
```
Note: The very first time you run this command, the latest image will be pulled from docker-hub
* To run commands inside the container, open multiple bash sessions in new terminal windows using
```sh
docker exec -it <container name> bash
```
Navigate into /kinetic or /melodic to view all the folders and files which are present in the \<host file system path\>
```sh
cd /kinetic
ls
```
In a similar manner, the catkin_workspace can be created and built, and different ROS nodes can be launched from different bash terminals of the same container
* To stop and remove the container, use ctrl+c followed by 
```sh
docker-compose -f industrial/start-container.yml down
```

## 2. Manually building the image 
* It is also possible to locally build the image using the dockerfiles in this repository.
The images can be built using docker-compose.yml by running the following command
```sh
docker-compose -f industrial/docker-compose.yml build 
```
or <br>
To build a single image by manually specifying the build args use following command
```sh
docker build --build-arg ROS_DISTRO=<ros-distribution> --build-arg UID=$(id -u) --build-arg GID=$(id -g) --build-arg UNAME=$USER <image name> .
```

* The locally built image can then used along with the existing docker-compose file start-container.yml by modifying the image name from `bitbots/bitbots-industrial:<ros_dist>-base` to \<image name\> and following the previously mentioned instructions.
