# syntax=docker/dockerfile:1
# check=error=true

FROM python:3-slim

ENV ANSIBLE_PIPELINING=true
ENV ANSIBLE_PERSISTENT_CONTROL_PATH_DIR=/tmp/ansible-ssh-%%h-%%p-%%r
ENV ANSIBLE_RETRY_FILES_ENABLED=false
ENV ANSIBLE_STDOUT_CALLBACK=debug

WORKDIR /app

RUN adduser -u 1000 ansible && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends postgresql-common && \
    /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh -y && \
    apt-get install -y --no-install-recommends bash git mariadb-client openssh-client rsync sshpass postgresql-client-9.6 postgresql-client-10 postgresql-client-11 postgresql-client-12 postgresql-client-13 postgresql-client-14 postgresql-client-15 postgresql-client-16 postgresql-client-17 postgresql-client-18 && \
    rm -rf /var/lib/apt/lists/* && \
    pip install --no-cache-dir ansible-core

USER ansible

COPY --chown=1000:1000 ./requirements.yml /tmp/requirements.yml

RUN ansible-galaxy install -r /tmp/requirements.yml

COPY --chown=1000:1000 . /home/ansible/.ansible/roles/lephare.ansible-deploy/
