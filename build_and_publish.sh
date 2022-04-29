# Build and publish images
# Copyright b-it-bots, Hochschule Bonn-Rhein-Sieg

DEPLOYMENT=""
CONTAINER_REGISTRY=""
PUBLISH="all"

if [ $# -eq 0 ]
then
  echo "Usage: bash build-and-deploy.sh"
  echo " "
  echo "options:"
  echo "-h, --help                    show brief help"
  echo "-c, --cuda                    cuda image tag e.g. 11.3.1-cudnn8-runtime-ubuntu20.04, default: 11.3.1-cudnn8-runtime-ubuntu20.04"
  echo "-d, --deployment              deployment (dev or prod), default: is empty or not published to registry"
  echo "-r, --registry                container registry e.g. ghcr.io for GitHub container registry, default: docker hub"
  echo "-p, --publish                 option whether to publish <all> or <latest> (default: all), all means publish all tags"
  exit 0
fi

while test $# -gt 0; do
  case "$1" in
    -h|--help)
      echo "Usage: bash build-and-deploy.sh"
      echo " "
      echo "options:"
      echo "-h, --help                show brief help"
      echo "-c, --cuda                cuda image tag e.g. 11.3.1-cudnn8-runtime-ubuntu20.04, default: 11.3.1-cudnn8-runtime-ubuntu20.04"
      echo "-d, --deployment          deployment (dev or prod), default: is empty or not published to registry"
      echo "-r, --registry            container registry e.g. ghcr.io for GitHub container registry, default: docker hub"
      echo "-p, --publish             option whether to publish <all> tags or <latest> tags only (default: all)"
      exit 0
      ;;
    -c|--cuda)
      CUDA_VERSION="$2"
      shift
      shift
      ;;
    -d|--deployment)
      DEPLOYMENT="$2"
      shift
      shift
      ;;
    -r|--registry)
      CONTAINER_REGISTRY="$2"
      shift
      shift
      ;;
    -p|--publish)
      PUBLISH="$2"
      shift
      shift
      ;;
    *)
      break
      ;;
  esac
done

if [ -z "$CUDA_VERSION" ]
then
  echo "Cuda version is not set, setting it to default 11.3.1-cudnn8-runtime-ubuntu20.04"
  CUDA_VERSION=11.3.1-cudnn8-runtime-ubuntu20.04
fi
echo "Cuda image version: $CUDA_VERSION"

echo "Image version: $VERSION"
if [ -z "$CONTAINER_REGISTRY" ]
then
  echo "Container registry is not set!. Using docker hub registry"
  CONTAINER_REG_OWNER=bitbots
else
  echo "Using $CONTAINER_REGISTRY registry"
  OWNER=b-it-bots/docker
  CONTAINER_REG_OWNER=$CONTAINER_REGISTRY/$OWNER
fi

echo "Container registry/owner = $CONTAINER_REG_OWNER"
echo "Deployment: $DEPLOYMENT"

function build_and_publish_gpu_notebook {
  cd gpu-notebook
  GPU_NOTEBOOK_TAG=$CONTAINER_REG_OWNER/gpu-notebook:$CUDA_VERSION 

  #prepare docker file
  bash generate_dockerfile.sh

  docker build -t $GPU_NOTEBOOK_TAG --build-arg ROOT_CONTAINER=nvidia/cuda:$CUDA_VERSION .build/ 
  if docker run -it --rm -d -p 8880:8888 $GPU_NOTEBOOK_TAG;
  then
    echo "$GPU_NOTEBOOK_TAG is running";
  else
    echo "Failed to run $GPU_NOTEBOOK_TAG" && exit 1;
  fi

  if [ "$PUBLISH" = "all" ]
  then
    echo "Pushing $GPU_NOTEBOOK_TAG"
    docker push $GPU_NOTEBOOK_TAG
  else
    echo "None is published"
  fi
}

function build_and_publish_base_image {
  cd base
  BASE_PORT=5000
  for ROS_DIST in */;
  do
    ROS_DISTRO=${ROS_DIST%/}
    BASE_IMAGE_TAG=$CONTAINER_REG_OWNER/bitbots-base:$ROS_DISTRO
    echo "Building base image $BASE_IMAGE_TAG"
    docker build -t $BASE_IMAGE_TAG $ROS_DISTRO

    if docker run -it --rm -d -p $BASE_PORT:$BASE_PORT $BASE_IMAGE_TAG;
    then
      echo "$BASE_IMAGE_TAG is running";
    else
      echo "Failed to run $BASE_IMAGE_TAG" && exit 1;
    fi

    let "BASE_PORT+=1"
  done

  if [ "$PUBLISH" = "all" ]
  then
    for ROS_DIST in */;
    do
      ROS_DISTRO=${ROS_DIST%/}
      BASE_IMAGE_TAG=$CONTAINER_REG_OWNER/bitbots-base:$ROS_DISTRO
      echo "Publishing base image $BASE_IMAGE_TAG"
      docker push $BASE_IMAGE_TAG
  done
  else
    echo "No base image is published"
  fi
  cd ..
}

function build_and_publish_domestic_image {
  cd domestic
  BASE_PORT=6000
  for ROS_DIST in */;
  do
    ROS_DISTRO=${ROS_DIST%/}
    DOMESTIC_IMAGE_TAG=$CONTAINER_REG_OWNER/bitbots-domestic:$ROS_DISTRO-base
    echo "Building image $DOMESTIC_IMAGE_TAG"
    docker build -t $DOMESTIC_IMAGE_TAG $ROS_DISTRO

    if docker run -it --rm -d -p $BASE_PORT:$BASE_PORT $DOMESTIC_IMAGE_TAG;
    then
      echo "$DOMESTIC_IMAGE_TAG is running";
    else
      echo "Failed to run $DOMESTIC_IMAGE_TAG" && exit 1;
    fi

    let "BASE_PORT+=1"
  done

  if [ "$PUBLISH" = "all" ]
  then
    for ROS_DIST in */;
    do
      ROS_DISTRO=${ROS_DIST%/}
      DOMESTIC_IMAGE_TAG=$CONTAINER_REG_OWNER/bitbots-domestic:$ROS_DISTRO-base
      echo "Publishing image $DOMESTIC_IMAGE_TAG"
      docker push $DOMESTIC_IMAGE_TAG
  done
  else
    echo "No domestic image is published"
  fi
  cd ..
}

# build and push docker image
build_and_publish_gpu_notebook
build_and_publish_base_image
build_and_publish_domestic_image
