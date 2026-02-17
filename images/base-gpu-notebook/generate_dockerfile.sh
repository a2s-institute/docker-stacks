#!/usr/bin/env bash

# generate dockerfile based on different cuda versions
function generate_dockerfile {
  CUDA_VERSION_DIR=$1
  BUILD_DIR=".build/$CUDA_VERSION_DIR"

  mkdir -p $BUILD_DIR
  
  # Set the path of the generated Dockerfile
  export DOCKERFILE="$BUILD_DIR/Dockerfile"
  export STACKS_DIR=".build/docker-stacks"

  echo "
  ############################################################################
  #################### Base image ############################################
  ############################################################################
  " >> $DOCKERFILE

  cat $CUDA_VERSION_DIR/Dockerfile >> $DOCKERFILE

  # Copy xfce desktop configuration
  cp user-dirs.defaults $BUILD_DIR

  cat Dockerfile.libs >> $DOCKERFILE
  rsync --exclude 'Dockerfile' $CUDA_VERSION_DIR/* $BUILD_DIR/

}

for dir in */; do
  CUDA_VERSION_DIR=${dir%*/}
  echo "Creating build dir for $CUDA_VERSION_DIR"
  generate_dockerfile $CUDA_VERSION_DIR
done
