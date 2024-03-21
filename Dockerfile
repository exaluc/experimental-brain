# syntax=docker/dockerfile:1

ARG DEBIAN_VERSION=bullseye

################################################################################
# Use debian image as copy image for final stage.
# https://hub.docker.com/_/debian
################################################################################
FROM debian:${DEBIAN_VERSION}-slim AS copy

# Set working directory.
WORKDIR /copy

# copy latest brain-dot-fr-server
COPY ./brain-dot-fr-server ./brain-dot-fr-server

# Make brain-dot-fr-server executable.
RUN chmod +x ./brain-dot-fr-server

################################################################################
# Use scratch image as final image.
# https://hub.docker.com/_/scratch
################################################################################
FROM debian:${DEBIAN_VERSION}-slim AS final

# Create user to run brain-dot-fr-server as non-root.
RUN addgroup --gid 1000 user
RUN adduser --uid 1000 --gid 1000 --disabled-password --gecos "" user

# Switch to user.
USER user

# Set working directory.
WORKDIR /usr/src/app

# Copy brain-dot-fr-server from copy image.
COPY --from=copy /copy/brain-dot-fr-server ./brain-dot-fr-server

# Expose 8080 port.
EXPOSE 8080

# Set entrypoint.
ENTRYPOINT ["/bin/sh", "/usr/src/app/brain-dot-fr-server", "--host", "0.0.0.0"]