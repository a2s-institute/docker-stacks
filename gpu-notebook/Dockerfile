ARG BASE_CONTAINER=ghcr.io/a2s-institute/docker-stacks/gpu-base-notebook:11.8.0-cudnn8-runtime-ubuntu22.04

FROM $BASE_CONTAINER

LABEL maintainer="Mohammad Wasil <e2x@inf.h-brs.de>"

ARG PYTORCH_CUDA=11.8

USER root

# Install apt packages
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
RUN echo "deb https://packages.cloud.google.com/apt coral-edgetpu-stable main" | tee /etc/apt/sources.list.d/coral-edgetpu.list

RUN apt-get update && \
    apt-get install -y edgetpu-compiler && \
    rm -rf /var/lib/apt/lists/*

USER $NB_USER

# install gh cli
RUN conda install gh --channel conda-forge

COPY requirements.txt /tmp/requirements.txt
RUN pip install --upgrade pip 
RUN pip install --no-cache-dir -r /tmp/requirements.txt

# install pytorch
RUN conda install pytorch torchvision torchaudio pytorch-cuda=$PYTORCH_CUDA -c pytorch -c nvidia

# Install nbzip
RUN pip install --no-cache-dir nbzip==0.1.0 && \
    jupyter serverextension enable  --sys-prefix --py nbzip && \
    jupyter nbextension     install --sys-prefix --py nbzip && \
    jupyter nbextension     enable  --sys-prefix --py nbzip

# Install graphviz via conda
RUN conda install graphviz

USER root
RUN rm /tmp/requirements.txt

USER $NB_USER

EXPOSE 8888

# Configure container startup
ENTRYPOINT ["tini", "-g", "--"]
CMD ["start-notebook.sh"]
