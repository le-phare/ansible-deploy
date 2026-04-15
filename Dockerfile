# syntax=docker/dockerfile:1
# check=error=true

FROM python:3-alpine3.22

ENV ANSIBLE_PIPELINING=true
ENV ANSIBLE_PERSISTENT_CONTROL_PATH_DIR=/tmp/ansible-ssh-%%h-%%p-%%r
ENV ANSIBLE_RETRY_FILES_ENABLED=false
ENV ANSIBLE_STDOUT_CALLBACK=debug

WORKDIR /app

RUN adduser -u 1000 -D ansible && \
    apk add --no-cache bash git mysql-client openssh-client postgresql15-client postgresql16-client postgresql17-client rsync sshpass && \
    apk add --no-cache --virtual build-dependencies gcc libffi-dev musl-dev && \
    pip install --no-cache-dir ansible ansible-core~=2.17.1 && \
    apk del build-dependencies

USER ansible

COPY ./requirements.yml /tmp/requirements.yml

RUN ansible-galaxy install -r /tmp/requirements.yml

COPY --link . /home/ansible/.ansible/roles/lephare.ansible-deploy/
