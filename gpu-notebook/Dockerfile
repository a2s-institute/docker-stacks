ARG BASE_CONTAINER=ghcr.io/b-it-bots/docker/gpu-base-notebook:11.3.1-cudnn8-runtime-ubuntu20.04

FROM $BASE_CONTAINER

LABEL maintainer="b-it-bots <robotics@h-brs.de>"

USER root

#Install Google Edge TPU Compiler
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
RUN echo "deb https://packages.cloud.google.com/apt coral-edgetpu-stable main" | tee /etc/apt/sources.list.d/coral-edgetpu.list

# Install nvtop to monitor the gpu tasks
RUN add-apt-repository ppa:flexiondotorg/nvtop

RUN apt-get update && \
    apt-get install -y libgl1-mesa-dev vim htop curl software-properties-common && \
    apt-get install -y cmake libncurses5-dev libncursesw5-dev git sox && \
    apt-get install -y edgetpu-compiler nvtop zip && \
    rm -rf /var/lib/apt/lists/*

USER $NB_USER

# install gh cli
RUN conda install gh --channel conda-forge

COPY requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt

# install pytorch
RUN pip install --upgrade pip 
RUN pip install torch==1.11.0+cu113 torchvision==0.12.0+cu113 torchaudio==0.11.0+cu113 -f https://download.pytorch.org/whl/cu113/torch_stable.html

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
