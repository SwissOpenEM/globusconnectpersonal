FROM ubuntu

ARG TARGETARCH
# Debug mode
ENV VERBOSE=false
# Endpoint description, optional
ENV DESCRIPTION=
# Setup key for the initial run
ENV SETUP_KEY=
VOLUME /home/appuser/data

# Install dependencies
RUN apt update && \
    apt install -y --no-install-recommends tk tcllib wget python3 python3-pip python3-tk && \
    apt clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Create a user to run the Globus ct Personal client since it cannot be run as root
RUN useradd appuser && \
    mkdir /home/appuser /globus && \
    chown appuser:appuser /home/appuser /globus

USER appuser

WORKDIR /tmp
# Install Globus Connect Personal client
RUN if [ "$TARGETARCH" = "amd64" ]; then \
        wget -O globusconnectpersonal-latest.tar.gz https://downloads.globus.org/globus-connect-personal/linux/stable/globusconnectpersonal-latest.tgz; \
    elif [ "$TARGETARCH" = "arm64" ]; then \
        wget -O globusconnectpersonal-latest.tar.gz https://downloads.globus.org/globus-connect-personal/linux_aarch64/stable/globusconnectpersonal-aarch64-latest.tgz; \
    else \
        echo "Unsupported architecture: $TARGETARCH"; exit 1; \
    fi && \
    tar -xzf globusconnectpersonal-latest.tar.gz && \
    rm globusconnectpersonal-latest.tar.gz && \
    mv globusconnectpersonal-*/* /globus/ && \
    rm -r globusconnectpersonal-*/

WORKDIR /globus

COPY docker-entrypoint.sh /docker-entrypoint.sh

WORKDIR /home/appuser/

ENTRYPOINT [ "/docker-entrypoint.sh" ]
