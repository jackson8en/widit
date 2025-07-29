# syntax=docker/dockerfile:1.4
ARG BASE_IMAGE

FROM alpine AS validator
ARG BASE_IMAGE
RUN if [ "${BASE_IMAGE}" = "undefined" ]; then echo "Error: BASE_IMAGE is not defined!" >&2; exit 1; fi

# BASE_IMAGE is validated in the previous stage
FROM ${BASE_IMAGE}

# Copy wsl-layer and setup script to temporary location
COPY wsl-layer/ /tmp/wsl-layer/
COPY setup-wsl-layer.sh /tmp/

# Run the setup script to handle permissions and copying
RUN chmod +x /tmp/setup-wsl-layer.sh && \
    /tmp/setup-wsl-layer.sh && \
    rm -rf /tmp/wsl-layer /tmp/setup-wsl-layer.sh

