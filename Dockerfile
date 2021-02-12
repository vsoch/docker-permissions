FROM ubuntu:20.04

# This example is derived from https://vsupalov.com/docker-shared-permissions/
# The user id and group id are required as build arguments to map to the container
ARG USER_ID
ARG GROUP_ID

RUN addgroup --gid $GROUP_ID squidward
RUN adduser --disabled-password --gecos '' --uid $USER_ID --gid $GROUP_ID squidward
USER squidward
