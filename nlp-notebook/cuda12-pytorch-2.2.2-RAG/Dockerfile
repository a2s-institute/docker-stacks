ARG BASE_IMAGE=quay.io/a2s-institute/ml-notebook:cuda12-pytorch-2.2.2

FROM $BASE_IMAGE

LABEL maintainer="Mohammad Wasil <e2x@inf.h-brs.de>"

USER $NB_USER

COPY requirements.txt /tmp/requirements.txt
COPY chroma_fix.sh /tmp/chroma_fix.sh
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r /tmp/requirements.txt



USER root

RUN curl -fsSL https://ollama.com/install.sh | sh

RUN chmod +x /tmp/chroma_fix.sh && /tmp/chroma_fix.sh

# clean up
RUN rm /tmp/requirements.txt && \
    /opt/conda/bin/conda clean -afy && \
    find /opt/conda/ -follow -type f -name '*.a' -delete && \
    find /opt/conda/ -follow -type f -name '*.pyc' -delete && \
    find /opt/conda/ -follow -type f -name '*.js.map' -delete

USER $NB_USER

CMD ["ollama","serve"]