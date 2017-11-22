#!/bin/bash
#-------------------------------------------------------------------------------
# Author: Lukasz Janyst <lukasz@jany.st>
# Date: 22.11.2017
#-------------------------------------------------------------------------------

set -e

#-------------------------------------------------------------------------------
# Figure out the user home directory - it's not always set when called
# from apache
#-------------------------------------------------------------------------------
USERNAME=`id -u -n`
HOME=`getent passwd ${USERNAME} | awk -F":" '{print $6}'`
ENVYRC="${HOME}/.envyrc"

#-------------------------------------------------------------------------------
# Diagnostics helpers
#-------------------------------------------------------------------------------
function debug() {
    if [ x${ENVY_DEBUG} != x ]; then
        echo ${@} >&2
    fi
}

function warning() {
    echo ${@} >&2
}

debug "[i] === Envy Diangostics ==="
debug "[i] Username: ${USERNAME}"
debug "[i] Home: ${HOME}"

#-------------------------------------------------------------------------------
# Decode the commandline params
#-------------------------------------------------------------------------------
read -r -a ARGS <<< ${1}
shift
ENV=`echo ${ARGS[1]} | tr '[[:lower:]]' '[[:upper:]]'`
PROG=${ARGS[0]}

#-------------------------------------------------------------------------------
# Check if the environment definition file exists and is readable
#-------------------------------------------------------------------------------
debug "[i] Environment: $ENV"
if [ -r "${ENVYRC}" ]; then
    debug "[i] Sourcing ${ENVYRC}"
    . ${ENVYRC}
    I=
    eval "ENV_FILE=\$ENV_${ENV}"
    if [ -r "${ENV_FILE}" ]; then
        debug "[i] Sourcing the configured environment file: ${ENV_FILE}"
        . ${ENV_FILE}
    else
        warning "[!] Configured environment file \"${ENV_FILE}\" cannot be read. Ignoring!"
    fi
else
    warning "[!] Configuration file ${ENVYRC} is missing. Ignoring the environment setting!"
fi

#-------------------------------------------------------------------------------
# Search for the executable
#-------------------------------------------------------------------------------
debug "[i] Interpreter: $PROG"
debug "[i] Script's commandline arguments: ${@}"

PROG_PATH=`which ${PROG} 2>/dev/null`
if [ ! -x "${PROG_PATH}" ]; then
      warning "Cannot find ${PROG}"
      exit 1
fi
debug "[i] Interpreter path: ${PROG_PATH}"

exec ${PROG_PATH} "${@}"
