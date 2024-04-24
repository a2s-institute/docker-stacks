ARG BASE_IMAGE=quay.io/a2s-institute/base-gpu-notebook:cuda12-pytorch-2.2.2

FROM $BASE_IMAGE

LABEL maintainer="Mohammad Wasil <e2x@inf.h-brs.de>"

USER root

RUN apt update -y && \
    apt install -y build-essential && \
    rm -rf /var/lib/apt/lists/*

USER root
RUN mamba install -y "qgis=3.36.1" -c conda-forge

# clean up
RUN /opt/conda/bin/conda clean -afy && \
    find /opt/conda/ -follow -type f -name '*.a' -delete && \
    find /opt/conda/ -follow -type f -name '*.pyc' -delete && \
    find /opt/conda/ -follow -type f -name '*.js.map' -delete

USER $NB_USER

