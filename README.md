[<!--lint ignore no-dead-urls-->![Build Status](https://github.com/a2s-institute/docker-stacks/workflows/CI/badge.svg)](https://github.com/a2s-institute/docker-stacks/actions?workflow=CI)

# a2s-institute docker images

## GPU Notebook

This image contains several packages for deep learning projects with NVidia GPU support.

* Build notebook image with gpu support
  ```
  bash build_and_publish.sh --registry ghcr.io --publish ""
  ```

  You can build this image using different cuda versions available [here](https://hub.docker.com/r/nvidia/cuda/tags).

* Run the image locally
  ```
  docker run --gpus all --name gpu-notebook -it --rm -d -p 8880:8888 ghcr.io/b-it-bots/docker/gpu-notebook:cuda11.3.1-ubuntu20.04
  ```

* Login to the container
  ```
  docker exec -ti gpu-notebook bash

  # check nvidia
  nvidia-smi
  ``` 
