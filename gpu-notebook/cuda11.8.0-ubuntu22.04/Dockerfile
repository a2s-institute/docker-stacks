ARG BASE_IMAGE=ghcr.io/a2s-institute/docker-stacks/base-gpu-notebook:cuda11.8.0-ubuntu22.04

FROM $BASE_IMAGE

LABEL maintainer="Mohammad Wasil <e2x@inf.h-brs.de>"

ARG PYTORCH_CUDA_VERSION=cu118

USER root

# Install apt packages
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
RUN echo "deb https://packages.cloud.google.com/apt coral-edgetpu-stable main" | tee /etc/apt/sources.list.d/coral-edgetpu.list

RUN apt update -y && \
    apt install -y edgetpu-compiler && \
    apt install -y libxkbcommon0 libxkbcommon-x11-0 && \
    rm -rf /var/lib/apt/lists/*

USER $NB_USER

# Github cli and graphviz
RUN conda install gh --channel conda-forge && \
    conda install python=3.11 && \
    conda install graphviz

COPY requirements.txt /tmp/requirements.txt
RUN pip install --upgrade pip && \
    pip install --no-cache-dir torch==2.0.1+cu118 torchvision==0.15.2+cu118 torchaudio --index-url https://download.pytorch.org/whl/cu118 && \
    pip install --no-cache-dir -r /tmp/requirements.txt
    # does not work with jupyter_server
    #jupyter serverextension enable  --sys-prefix --py nbzip && \
    #jupyter nbextension     install --sys-prefix --py nbzip && \
    #jupyter nbextension     enable  --sys-prefix --py nbzip

USER root

# clean up
RUN rm /tmp/requirements.txt && \
    /opt/conda/bin/conda clean -afy && \
    find /opt/conda/ -follow -type f -name '*.a' -delete && \
    find /opt/conda/ -follow -type f -name '*.pyc' -delete && \
    find /opt/conda/ -follow -type f -name '*.js.map' -delete

USER $NB_USER

EXPOSE 8888

# Configure container startup
ENTRYPOINT ["tini", "-g", "--"]
CMD ["start-notebook.sh"]
