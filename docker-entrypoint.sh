#! /bin/bash
# Start globusconnectpersonal
#
# For normal running a `.globusonline` directory is required containing configuration
# and keys. This can be mounted (writable, with owner 1001) or else copied from a
# supplied $GLOBUSONLINE_TGZ.
#
# If no configuration is found, the container will run in `-setup` mode. This requires
# either an interactive session or else the $SETUP_KEY variable; See
# https://docs.globus.org/globus-connect-personal/troubleshooting-guide/#generating-gcp-setup-key
#
# Variables:
# - SETUP_KEY: Run setup process (setup only)
# - DESCRIPTION: Endpoint description (setup only)
# - VERBOSE: [yes|NO] enable debugging
# - GLOBUSONLINE_TGZ: path to a tarball, which will be expanded in the home directory.
#                     Useful for providing a .globusonline/lta directory with config files.
#                     Default: /globusonline.tgz

set -euo pipefail
shopt -s nocasematch


GCP=/globus/globusconnectpersonal

# Untar config files if specified
if [[ -f "${GLOBUSONLINE_TGZ:-/globusonline.tgz}" ]]; then
    tar --no-xattrs --no-acls --exclude="._*" -xzf "${GLOBUSONLINE_TGZ:-/globusonline.tgz}" -C /home/appuser/;
fi

# Do setup
if ! [ -f /home/appuser/.globusonline/lta/client-id.txt ]; then
    args=("$GCP" -setup)
    args_safe=($(basename $GCP) -setup) # safe version for logging
    # check for a setup key
    if [ -n "${SETUP_KEY:-}" ]; then
        args+=(--setup-key "$SETUP_KEY")
        args_safe+=(--setup-key '$SETUP_KEY')
    fi
    # check for description
    if [ -n "${DESCRIPTION:-}" ]; then
        args+=(--description "$DESCRIPTION")
        args_safe+=(--description '"'"$DESCRIPTION"'"')
    fi

    echo "RUN ${args_safe[@]}"
    "${args[@]}" || {
        echo "RUN cat ~/.globusonline/lta/register.log";
        cat /home/appuser/.globusonline/lta/register.log;
        exit 1
    }
fi

# Start GCP
args=("$GCP")
case "${VERBOSE:-false}" in
t*|on|1)
    args+=(-debug)
    ;;
*)
    args+=(-start)
esac

if [ -d "$HOME/data/" ]; then
    args+=(-restrict-paths "rw~/data")
else
    args+=(-restrict-paths "rw~/")
fi

echo "RUN ${args[*]}"
$GCP -version
exec "${args[@]}"