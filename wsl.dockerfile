# syntax=docker/dockerfile:1.4

# This is the final layer to turn a docker image into a WSL image.
# creator.sh will layer this on top of your base image or custom
# dockerfile to create a WSL-compatible image.

ARG BASE_IMAGE
ARG OUTPUT_NAME=widit-custom-distro

FROM alpine AS validator
ARG BASE_IMAGE
RUN if [ "${BASE_IMAGE}" = "undefined" ]; then echo "Error: BASE_IMAGE is not defined!" >&2; exit 1; fi

# BASE_IMAGE is validated in the previous stage
FROM ${BASE_IMAGE}

ARG OUTPUT_NAME

# Copy wsl-layer and setup script to temporary location
COPY wsl-layer/ /tmp/wsl-layer/
COPY setup-wsl-layer.sh /tmp/

# Run the setup script to handle permissions and copying
RUN chmod +x /tmp/setup-wsl-layer.sh && \
    OUTPUT_NAME="$OUTPUT_NAME" /tmp/setup-wsl-layer.sh && \
    rm -rf /tmp/wsl-layer /tmp/setup-wsl-layer.sh

