#!/bin/sh

#
# This file and its contents are supplied under the terms of the
# Common Development and Distribution License ("CDDL)". You may
# only use this file in accordance with the terms of the CDDL.
#
# A full copy of the text of the CDDL should have accompanied this
# source. A copy of the CDDL is also available via the Internet at
# http://www.illumos.org/license/CDDL.
#

#
# Copyright 2025 Till Wegmueller All rights reserved.
#

. /lib/svc/share/smf_include.sh

# Set a reasonable ulimit
ulimit -n 65535

CADDY_USR_ROOT=/usr/local
CADDY_ETC_ROOT=/etc/caddy

STARTUP_OPTIONS=

PLATFORM_DIR=

getprop() {
    PROPVAL=""
    svcprop -q -p $1 ${SMF_FMRI}
    if [ $? -eq 0 ] ; then
        PROPVAL=`svcprop -p $1 ${SMF_FMRI}`
        if [ "${PROPVAL}" = "\"\"" ] ; then
            PROPVAL=""
        fi
        return
    fi
    return
}

getprop httpd/config_dir
if [ "${PROPVAL}" != "" ] ; then
    CADDY_ETC_ROOT=$PROPVAL
fi

CADDY_HOME=${CADDY_USR_ROOT}
CADDY_BIN=${CADDY_HOME}/bin

getprop httpd/startup_options
if [ "${PROPVAL}" != "" ] ; then
        echo startupoptions set
        echo val=${PROPVAL}
        STARTUP_OPTIONS="${PROPVAL} -k"
fi

# Export CADDY_ETC_ROOT as an environment variable for use in config files
export CADDY_ETC_ROOT="${CADDY_ETC_ROOT}"

case "$1" in
start)
        ${CADDY_BIN}/caddy ${STARTUP_OPTIONS} -c ${CADDY_ETC_ROOT}/Caddyfile 2>&1
        ;;
*)
        echo "Usage: $0 {start}"
        exit $SMF_EXIT_ERR_CONFIG
        ;;
esac


if [ $? -ne 0 ]; then
    echo "Server failed to start. Check the error log (defaults to /var/caddy/logs/error.log) for more information, if any."
    exit $SMF_EXIT_ERR_FATAL
fi

exit $SMF_EXIT_OK
