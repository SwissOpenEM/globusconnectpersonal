# globus-docker

Run Globus Connect Personal in a Docker container.

## Usage

```shell
# Run with gui
docker build -t globus .
# You can change the volume to point to your data
docker run -it --rm --name globus --volume $HOME/Datasets:/home/appuser/data globus
# Run with gui
docker run -it --rm --name globus -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix --volume $HOME/Datasets:/home/appuser/data globus

# Run with gui
cd globusconnectpersonal-3.2.0 # or whatever version you have
./globusconnectpersonal -setup # follow instructions to connect to your account
./globusconnectpersonal -gui # or -start to run in cli
# The gui will open, click connect to start the endpoint
```
