FROM alpine

ENV ANSIBLE_PIPELINING=true
ENV ANSIBLE_PERSISTENT_CONTROL_PATH_DIR=/tmp/ansible-ssh-%%h-%%p-%%r
ENV ANSIBLE_RETRY_FILES_ENABLED=false
ENV ANSIBLE_STDOUT_CALLBACK=debug

RUN echo "===> Installing sudo to emulate normal OS behavior..."  && \
    apk --update add sudo                                         && \
    \
    \
    echo "===> Adding Python runtime..."  && \
    apk --update add python3 py-pip openssl ca-certificates    && \
    apk --update add --virtual build-dependencies \
      python3-dev libffi-dev openssl-dev build-base rust cargo && \
    pip install --upgrade pip cffi                            && \
    \
    \
    echo "===> Installing Ansible..."  && \
    pip install ansible                && \
    \
    \
    echo "===> Installing handy tools (not absolutely required)..."  && \
    pip install --upgrade pycrypto pywinrm                           && \
    apk --update add sshpass openssh-client rsync postgresql git mysql-client npm make && \
    \
    \
    echo "===> Removing package list..."  && \
    apk del build-dependencies            && \
    rm -rf /var/cache/apk/*               && \
    \
    \
    echo "===> Adding hosts for convenience..."  && \
    mkdir -p /etc/ansible                        && \
    echo 'localhost' > /etc/ansible/hosts


ARG ANSIBLE_DEPLOY_BRANCH
ENV ANSIBLE_DEPLOY_BRANCH=${ANSIBLE_DEPLOY_BRANCH:-master}

RUN adduser -u 1000 -D ansible
WORKDIR /app

COPY ./requirements.yml /tmp/requirements.yml
RUN sed -i -r "s/(name: lephare.ansible-deploy)/\1\n    version: $ANSIBLE_DEPLOY_BRANCH/g" /tmp/requirements.yml

USER ansible
RUN ansible-galaxy install -r /tmp/requirements.yml
