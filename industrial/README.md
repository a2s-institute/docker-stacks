# Docker Image for BitBots Industrial
Docker images are available for **Ubuntu 16.04 based ROS-Kinetic** and **Ubuntu 18.04 based ROS-Melodic** environments with all the necessary ros packages and dependencies already installed. Hence, it is sufficient to clone the MAS industrial robotics repository and perform a hassle free catkin build and launching ROS nodes from within the docker container. <br>

Advantages of using this image over a local build:
* All necessary ROS dependencies and packages come bundled with the image
* Containers can easily be started by using docker compose
* Hassle free catkin build without any environment issues
* No user rights issues when creating/cloning folders from within the container
* ROS nodes and ROS master can be launched from within the container and can also communicate with nodes/clients running outside the container, on the local Ubuntu machine
* Supports GUI rendering for *gazebo* and *rviz*
* Source code for the ROS packages is stored locally and is only volume mounted in the container

## 1. Using docker-compose file start-container-<ros_dist>.yml

* Download the sample start-container-<ros_dist>.yml file from this repository and modify the following based on your requirements:
  * Change the \<host file system path\> (/home/iswariya/Documents/Robocup) to the folder where you have cloned the MAS industrial robotics repository and where you want your catkin workspace to be created
  Note: All files and folders available in the \<host file system path\> will be mapped to the \<mounted directory\> (/temp) inside the container
  * Modify the nvidia-390 with the version of nvidia driver installed in your system
  * $HOME/.rviz:/home/<ros_dist>_user/.rviz is optional. Favorite Rviz configurations which are stored in your local file system will be mounted onto your docker container
* Then run the following command from the folder containing the start-container.yml file. This spins up a container based on the bitbots/bitbots-industrial:<ros_dist>-base image
```sh
docker-compose -f start-container-<ros_dist>.yml up
```
Note: The very first time you run this command, the latest image will be pulled from docker-hub
* To run commands inside the container, open multiple bash sessions in new terminal windows using
```sh
docker exec -it <container name> bash
```
Navigate into /temp to view all the folders and files which are present in the \<host file system path\>
```sh
cd /temp
ls
```
In a similar manner, the catkin_workspace can be created and built, and different ROS nodes can be launched from different bash terminals of the same container
* To stop and remove the container, use ctrl+c followed by 
```sh
docker-compose -f start-container-<ros_dist>.yml down
```

## 2. Manually building the image 
* It is also possible to locally build the image using the dockerfiles in this repository. To build the image use the following command
```sh
docker build --build-arg UID=$(id -u) --build-arg GID=$(id -g) --build-arg UNAME=$USER <image name> .
```
* The locally built image can then used along with the existing docker-compose file start-container-<ros_dist>.yml by modifying the image name from `bitbots/bitbots-industrial:<ros_dist>-base` to \<image name\> and following the previously mentioned instructions.
