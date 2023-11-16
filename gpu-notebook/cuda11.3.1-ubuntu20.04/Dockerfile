ARG BASE_IMAGE=ghcr.io/a2s-institute/docker-stacks/base-gpu-notebook:cuda11.3.1-ubuntu20.04

FROM $BASE_IMAGE

LABEL maintainer="Mohammad Wasil <e2x@inf.h-brs.de>"

ARG PYTORCH_CUDA_VERSION=cu113

USER root

# Install apt packages
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
RUN echo "deb https://packages.cloud.google.com/apt coral-edgetpu-stable main" | tee /etc/apt/sources.list.d/coral-edgetpu.list

RUN apt-get update && \
    apt-get install -y edgetpu-compiler && \
    rm -rf /var/lib/apt/lists/*

USER $NB_USER

# Github cli and graphviz
RUN conda install gh --channel conda-forge && \
    conda install graphviz nb_conda_kernels

COPY requirements.txt /tmp/requirements.txt
RUN pip install --upgrade pip && \
    pip install --no-cache-dir torch==1.12.1+cu113 torchvision==0.13.1+cu113 torchaudio==0.12.1 --extra-index-url https://download.pytorch.org/whl/cu113 && \
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
