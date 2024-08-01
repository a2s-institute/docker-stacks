ARG BASE_IMAGE=quay.io/a2s-institute/ml-notebook:cuda12-pytorch-2.2.2

FROM $BASE_IMAGE

LABEL maintainer="Mohammad Wasil <mohammad.wasil@h-brs.de>"

USER root

# Install QGIS. It needs root
RUN mamba install -y "qgis=3.36.1" -c conda-forge
COPY --chown=$NB_UID:$NB_GID qgis/qgis.desktop /usr/share/applications/
COPY --chown=$NB_UID:$NB_GID qgis/qgis.desktop /usr/local/xfce-userdirs/Desktop/
RUN chmod +x /usr/share/applications/qgis.desktop

USER $NB_USER

COPY requirements.txt /tmp/requirements.txt

RUN pip install --no-cache-dir -r /tmp/requirements.txt

# clean up
USER root
RUN rm /tmp/requirements.txt && \
    /opt/conda/bin/conda clean -afy && \
    find /opt/conda/ -follow -type f -name '*.a' -delete && \
    find /opt/conda/ -follow -type f -name '*.pyc' -delete && \
    find /opt/conda/ -follow -type f -name '*.js.map' -delete

USER $NB_USER
