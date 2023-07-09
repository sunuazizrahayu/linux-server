#!/bin/bash

# input
read -p "Enter your gitlab-runner token: " REGISTRATION_TOKEN

# install gitlab-runner
docker run -d --name gitlab-runner --restart always \
  -v /srv/gitlab-runner/config:/etc/gitlab-runner \
  -v /var/run/docker.sock:/var/run/docker.sock \
  gitlab/gitlab-runner:latest

# register token
docker exec -it gitlab-runner \
gitlab-runner register -n \
  --url https://gitlab.com/ \
  --registration-token $REGISTRATION_TOKEN \
  --executor docker \
  --docker-image "alpine" \
  --docker-privileged \
  --docker-volumes "/var/run/docker.sock:/var/run/docker.sock"

# update config
docker restart gitlab-runner
