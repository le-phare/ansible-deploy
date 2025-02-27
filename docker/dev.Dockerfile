#
# Run : docker build -f Dockerfile.dev ..
#
FROM lephare/ansible:latest

COPY ./docker/requirements.yml /tmp/requirements.yml
RUN ansible-galaxy install -r /tmp/requirements.yml

COPY . /home/ansible/.ansible/roles/lephare.ansible-deploy
