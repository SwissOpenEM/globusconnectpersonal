# Globus Personal Connect Docker

Run Globus Connect Personal in a Docker container.

## Setup

The latest container can be pulled from github:

```sh
docker pull ghcr.io/swissopenem/globusconnectpersonal:main
```

Alternately, you can build locally:
```sh
docker build -t globuspersonalconnect .
```

Setup works best using a [GCP Setup Key](https://docs.globus.org/globus-connect-personal/troubleshooting-guide/#generating-gcp-setup-key)

1. Navigate to the Globus WebApp GCP [Setup
   Key](https://app.globus.org/file-manager/gcp?generate_key=true) page.
2. Generate and copy the "Setup key"
3. Add the `SETUP_KEY` variable in `.env`
4. Run the container:

```sh
docker run -it --name gcp --env-file .env \
    --volume $PWD/data:/home/appuser/data \
    globuspersonalconnect
```

If you see an error 'Setup Code XXX not found' this generally indicates that the setup
key has expired. Keys are only valid for one use. An interactive terminal (`-it`) seems
to be required for setup, but is not needed on later runs of the container.

Persisting the globus settings is done by seeding the `~/.globusonline` directory from a
tar file during the container startup. From the setup instance, save the settings as
follows:

```
docker exec gcp tar cz .globusonline > globusonline.tgz
```

Globus requires files in ~/.globusonline to be owned by a non-root user,
so directly mounting `.globusonline` as a volume fails.

## Running

After the initial setup, start the container as follows:

```sh
docker run -it --rm --name gcp --env-file .env \
    --volume $PWD/data:/home/appuser/data \
    --volume $PWD/globusonline.tgz:/globusonline.tgz \
    globuspersonalconnect
```

GPC will start using the previously saved `.globusonline` directory. The tarball path
within the container can also be set if needed using the `GLOBUSONLINE_TGZ` environment
variable (see docker-entrypoint.sh).

## GUI
*TODO needs update*

The image contains python and Tk packages, allowing gui usage:

```sh
# You can change the volume to point to your data
docker run -it --rm --name gcp --volume $HOME/Datasets:/home/appuser/data globuspersonalconnect
# Run with gui
docker run -it --rm --name gcp -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix --volume $HOME/Datasets:/home/appuser/data globuspersonalconnect

# Run with gui
cd /globus # or whatever version you have
./globusconnectpersonal -setup # follow instructions to connect to your account
./globusconnectpersonal -gui # or -start to run in cli
# The gui will open, click connect to start the endpoint
```

On MacOS the gui requires XQuartz to be installed. You may also need to set `xhost
+localhost` and use `-e DISPLAY=host.docker.internal:0`.