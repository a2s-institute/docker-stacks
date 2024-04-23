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
  #################### Dependency: jupyter/pytorch-notebook ##################
  ############################################################################
  " >> $DOCKERFILE

  cat $CUDA_VERSION_DIR/Dockerfile >> $DOCKERFILE

  echo "
  ############################################################################
  #################### Dependency: xfce4 desktop cfg #########################
  ############################################################################
  " >> $DOCKERFILE

  # Copy xfce desktop configuration
  cp user-dirs.defaults $BUILD_DIR

  echo "
  ############################################################################
  ################# Dependency: a2s cluster dependencies #####################
  ############################################################################
  " >> $DOCKERFILE

  cat Dockerfile.libs >> $DOCKERFILE

}

for dir in */; do
  CUDA_VERSION_DIR=${dir%*/}
  echo "Creating build dir for $CUDA_VERSION_DIR"
  generate_dockerfile $CUDA_VERSION_DIR
done
