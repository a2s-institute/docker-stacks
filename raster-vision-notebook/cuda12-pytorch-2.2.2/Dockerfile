ARG BASE_IMAGE=quay.io/a2s-institute/ml-notebook:cuda12-pytorch-2.2.2

FROM $BASE_IMAGE

LABEL maintainer="Mohammad Wasil <mohammad.wasil@h-brs.de>"

USER $NB_USER

COPY requirements.txt /tmp/requirements.txt

# install qgis
RUN mamba install -y "qgis=3.36.1" -c conda-forge

RUN pip install --no-cache-dir -r /tmp/requirements.txt

USER root

# clean up
RUN rm /tmp/requirements.txt && \
    /opt/conda/bin/conda clean -afy && \
    find /opt/conda/ -follow -type f -name '*.a' -delete && \
    find /opt/conda/ -follow -type f -name '*.pyc' -delete && \
    find /opt/conda/ -follow -type f -name '*.js.map' -delete

USER $NB_USER
