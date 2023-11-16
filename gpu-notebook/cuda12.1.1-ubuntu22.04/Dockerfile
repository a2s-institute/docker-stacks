ARG BASE_IMAGE=ghcr.io/a2s-institute/docker-stacks/base-gpu-notebook:cuda12.1.1-ubuntu22.04

FROM $BASE_IMAGE

LABEL maintainer="Mohammad Wasil <e2x@inf.h-brs.de>"

USER root

# Install apt packages
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
RUN echo "deb https://packages.cloud.google.com/apt coral-edgetpu-stable main" | tee /etc/apt/sources.list.d/coral-edgetpu.list

RUN apt update -y && \
    apt install -y edgetpu-compiler && \
    apt install -y libxkbcommon0 libxkbcommon-x11-0 && \
    apt install -y build-essential && \
    rm -rf /var/lib/apt/lists/*

USER $NB_USER

# Github cli and graphviz
RUN conda install -y gh --channel conda-forge && \
    conda install -y python=3.11 && \
    conda install -y graphviz nb_conda_kernels && \
    conda install -y pytorch==2.1.0 torchvision==0.16.0 torchaudio==2.1.0 pytorch-cuda=12.1 -c pytorch -c nvidia

COPY requirements.txt /tmp/requirements.txt
RUN pip install --upgrade pip && \
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
