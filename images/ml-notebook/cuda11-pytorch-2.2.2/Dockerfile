ARG BASE_IMAGE=quay.io/a2s-institute/base-gpu-notebook:cuda11-pytorch-2.2.2

FROM $BASE_IMAGE

LABEL maintainer="Mohammad Wasil <e2x@inf.h-brs.de>"

USER root

# Install apt packages
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - && \
    echo "deb https://packages.cloud.google.com/apt coral-edgetpu-stable main" | sudo tee /etc/apt/sources.list.d/coral-edgetpu.list
    
RUN apt update -y && \
    apt install -y edgetpu-compiler && \
    apt install -y libxkbcommon0 libxkbcommon-x11-0 && \
    apt install -y build-essential && \
    rm -rf /var/lib/apt/lists/*

# Change ownership if the directory exists
RUN if [ -d "/opt/conda/etc/jupyter/nbconfig/notebook.d" ]; then \
        chown -R $NB_UID:$NB_GID /opt/conda/etc/jupyter/nbconfig/notebook.d; \
    fi
 
USER $NB_USER

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
