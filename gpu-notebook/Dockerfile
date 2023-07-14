ARG BASE_CONTAINER=ghcr.io/a2s-institute/docker-stacks/gpu-base-notebook:11.8.0-cudnn8-runtime-ubuntu22.04

FROM $BASE_CONTAINER

LABEL maintainer="Mohammad Wasil <e2x@inf.h-brs.de>"

ARG PYTORCH_CUDA=cu118

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
RUN pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/$PYTORCH_CUDA

# Install nbzip
RUN jupyter serverextension enable  --sys-prefix --py nbzip && \
    jupyter nbextension     install --sys-prefix --py nbzip && \
    jupyter nbextension     enable  --sys-prefix --py nbzip

# Install graphviz via conda
RUN conda install graphviz

USER root
RUN rm /tmp/requirements.txt

# clean conda
RUN /opt/conda/bin/conda clean -afy \
    && find /opt/conda/ -follow -type f -name '*.a' -delete \
    && find /opt/conda/ -follow -type f -name '*.pyc' -delete \
    && find /opt/conda/ -follow -type f -name '*.js.map' -delete

USER $NB_USER

EXPOSE 8888

# Configure container startup
ENTRYPOINT ["tini", "-g", "--"]
CMD ["start-notebook.sh"]
