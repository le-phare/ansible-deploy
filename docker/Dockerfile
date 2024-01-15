FROM python:3-alpine

ENV ANSIBLE_PIPELINING=true
ENV ANSIBLE_PERSISTENT_CONTROL_PATH_DIR=/tmp/ansible-ssh-%%h-%%p-%%r
ENV ANSIBLE_RETRY_FILES_ENABLED=false
ENV ANSIBLE_STDOUT_CALLBACK=debug

RUN apk add --no-cache --update bash git mysql-client openssh-client postgresql rsync
RUN apk add --no-cache --virtual build-dependencies gcc libffi-dev musl-dev

RUN pip install --no-cache-dir ansible

RUN apk del build-dependencies

ARG ANSIBLE_DEPLOY_BRANCH
ENV ANSIBLE_DEPLOY_BRANCH=${ANSIBLE_DEPLOY_BRANCH:-master}

RUN adduser -u 1000 -D ansible
WORKDIR /app

COPY ./requirements.yml /tmp/requirements.yml
RUN sed -i -r "s/(name: lephare.ansible-deploy)/\1\n    version: $ANSIBLE_DEPLOY_BRANCH/g" /tmp/requirements.yml

USER ansible
RUN ansible-galaxy install -r /tmp/requirements.yml
