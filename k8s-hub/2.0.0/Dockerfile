ARG IMAGE_SOURCE=jupyterhub/k8s-hub:2.0.0
FROM $IMAGE_SOURCE

LABEL maintainer="DigiKlausur (E2x) project HBRS <mohammad.wasil@h-brs.de>"

USER root
RUN pip install --no-cache-dir pandas && \
    pip install --no-cache-dir git+https://github.com/jupyterhub/nativeauthenticator.git@main && \
    pip install --no-cache-dir git+https://github.com/DigiKlausur/miaauth.git@main && \
    pip install --no-cache-dir git+https://github.com/DigiKlausur/e2xhub.git@main && \
    pip install --no-cache-dir git+https://github.com/idiap/multiauthenticator@main

USER $NB_USER
