#!/bin/bash



# 
NUM_GPUS=$(nvidia-smi -L | wc -l)


# https://docs.docker.com/compose/gpu-support/
DOCKER_COMPOSE_YML="\
    deploy:
      resources:
        reservations:
          devices:
           - driver: nvidia
             capabilities: [utility, compute, video]
"

echo "${DOCKER_COMPOSE_YML}" >> "docker-compose.yml"
