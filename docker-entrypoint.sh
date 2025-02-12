#! /bin/bash
set -euo pipefail
shopt -s nocasematch

GCP=/globus/globusconnectpersonal

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
exec "${args[@]}"