# syntax=docker/dockerfile:1
# check=error=true

FROM python:3-alpine3.22

ENV ANSIBLE_PIPELINING=true
ENV ANSIBLE_PERSISTENT_CONTROL_PATH_DIR=/tmp/ansible-ssh-%%h-%%p-%%r
ENV ANSIBLE_RETRY_FILES_ENABLED=false
ENV ANSIBLE_STDOUT_CALLBACK=debug

WORKDIR /app

RUN adduser -u 1000 -D ansible && \
    apk add --no-cache bash git mysql-client openssh-client postgresql rsync sshpass && \
    apk add --no-cache --virtual build-dependencies gcc libffi-dev musl-dev && \
    pip install --no-cache-dir ansible ansible-core==2.15.4 && \
    apk del build-dependencies

USER ansible

COPY --chown=1000:1000 ./requirements.yml /tmp/requirements.yml

RUN ansible-galaxy install -r /tmp/requirements.yml

COPY --chown=1000:1000 . /home/ansible/.ansible/roles/lephare.ansible-deploy/
