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

# Install Globus Connect Personal client
RUN wget https://downloads.globus.org/globus-connect-personal/linux/stable/globusconnectpersonal-latest.tgz
RUN tar xzf globusconnectpersonal-latest.tgz
