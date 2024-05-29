FROM artifactory.wma.chs.usgs.gov/docker-official-mirror/debian:stable

LABEL maintainer="gw-w_vizlab@usgs.gov"

# Run updates and install curl
RUN apt-get update && \
      apt-get install -y ca-certificates curl gnupg && \
      mkdir -p /etc/apt/keyrings

# Enable the NodeSource repository and install nodejs version 20 (current LTS as of May 2024)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - &&\
      apt-get install -y nodejs

# Create temp directory for building viz app
RUN mkdir -p /tmp/water-bottling

# Copy source code
WORKDIR /tmp/water-bottling
COPY . .
# Set environment variables for build target and tile source and then run config.sh
ARG BUILDTARGET="test"
ARG VUE_BUILD_MODE="development"
ENV E_BUILDTARGET=$BUILDTARGET
ENV E_VUE_BUILD_MODE=$VUE_BUILD_MODE

# Build the Vue app.
RUN npm install
RUN chmod +x ./build.sh && ./build.sh

