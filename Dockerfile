FROM ubuntu

# Install depenedencies
RUN apt update; apt install -y tk tcllib wget
RUN apt install -y python3 python3-pip python3-tk

# Create a user to run the Globus Connect Personal client since it cannot be run as root
RUN useradd appuser
RUN mkdir /home/appuser
RUN chown appuser:appuser /home/appuser
USER appuser
WORKDIR /home/appuser/

ARG TARGETARCH

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
    mv globusconnectpersonal-*/ /home/appuser/globus;

WORKDIR /home/appuser/globus
VOLUME /home/appuser/data

CMD ["./globusconnectpersonal"]
