# Build and publish images
# Copyright a2s-institute, Hochschule Bonn-Rhein-Sieg

DEPLOYMENT=""
CONTAINER_REGISTRY=""
PUBLISH="all"

if [ $# -eq 0 ]
then
  echo "Usage: bash build-and-deploy.sh"
  echo " "
  echo "options:"
  echo "-h, --help                    show brief help"
  echo "-d, --deployment              deployment (dev or prod), default: is empty or not published to registry"
  echo "-r, --registry                container registry e.g. ghcr.io for GitHub container registry, default: docker hub"
  echo "-p, --publish                 option whether to publish <all> or <latest> (default: all), all means publish all tags"
  echo "-i, --image                   image to build base|domestic|gpu-notebook|all (default: all)"
  exit 0
fi

while test $# -gt 0; do
  case "$1" in
    -h|--help)
      echo "Usage: bash build-and-deploy.sh"
      echo " "
      echo "options:"
      echo "-h, --help                show brief help"
      echo "-d, --deployment          deployment (dev or prod), default: is empty or not published to registry"
      echo "-r, --registry            container registry e.g. ghcr.io for GitHub container registry, default: docker hub"
      echo "-p, --publish             option whether to publish <all> tags or <latest> tags only (default: all)"
      echo "-i, --image               image to build domestic|gpu-notebook|all (default: all)"
      exit 0
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
    -i|--image)
      IMAGE="$2"
      shift
      shift
      ;;
    *)
      break
      ;;
  esac
done

echo "Image version: $VERSION"
if [ -z "$CONTAINER_REGISTRY" ]
then
  echo "Container registry is not set!. Using docker hub registry"
  CONTAINER_REG_OWNER=bitbots
else
  echo "Using $CONTAINER_REGISTRY registry"
  OWNER=a2s-institute/docker-stacks
  CONTAINER_REG_OWNER=$CONTAINER_REGISTRY/$OWNER
fi

echo "Container registry/owner = $CONTAINER_REG_OWNER"
echo "Deployment: $DEPLOYMENT"

function build_and_publish_single_image {
  IMAGE_DIR=$1
  IMAGE_TAG=$2
  PORT=$3

  docker build -t $IMAGE_TAG $IMAGE_DIR

  if docker run -it --rm -d -p $PORT:$PORT $IMAGE_TAG;
  then
    echo "$IMAGE_TAG is running";
  else
    echo "Failed to run $IMAGE_TAG" && exit 1;
  fi

  if [ "$PUBLISH" = "all" ]
  then
    echo "Pushing $IMAGE_TAG"
    docker push $IMAGE_TAG
  else
    echo "None is published"
  fi
}

function build_and_publish {
  # Generate base dockerfile and images
  cd base-gpu-notebook
  bash generate_dockerfile.sh
  
  BASE_PORT=7000
  for dir in */; do
    # please test the build of the commit in https://github.com/jupyter/docker-stacks/commits/main in advance
    CUDA_VERSION_DIR=${dir%*/}
    IMAGE_DIR=.build/$CUDA_VERSION_DIR

    IMAGE_TAG=$CONTAINER_REG_OWNER/base-gpu-notebook:$CUDA_VERSION_DIR
    echo "Building image $IMAGE_TAG"
    build_and_publish_single_image $IMAGE_DIR $IMAGE_TAG $BASE_PORT

    let "BASE_PORT+=1"
  done  
  cd ..
  
  cd gpu-notebook
  NB_PORT=8000
  GPU_NOTEBOOK_DIR=gpu-notebook
  for dir in */; do
    echo "Dir $dir"
    # please test the build of the commit in https://github.com/jupyter/docker-stacks/commits/main in advance
    CUDA_VERSION_DIR=${dir%*/}
    IMAGE_DIR=$CUDA_VERSION_DIR

    IMAGE_TAG=$CONTAINER_REG_OWNER/gpu-notebook:$IMAGE_DIR
    echo "Building image $IMAGE_TAG"
    build_and_publish_single_image $IMAGE_DIR $IMAGE_TAG $NB_PORT

    let "NB_PORT+=1"
  done  
  cd ..
}

# build and push docker image
echo "Building and publishing images"
build_and_publish
