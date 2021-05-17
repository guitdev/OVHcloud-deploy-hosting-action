#!/usr/bin/env bash

function _USAGE
{
cat << EOF
Usage :
    ${_SCRIPT_NAME} [OPTIONS]
Options :
    -u  website_url     website url (ex: http://mydomain.ovh)
    -d  documentroot    documentroot directory relative to home directory (ex: www)
    -e  entrypoint      entrypoint (ex: app.py, index.js, config.ru)
    -p  publicdir       publicdir directory relative to documentroot (ex: public)
    -h                  show this message
Ex :
    ${_SCRIPT_NAME} -u http://mydomain.ovh -d www -e app.py -p public
EOF
exit 1
}

function _LOGS
{
    local _LEVEL="${1}"
    local _MESSAGE="${2}"
    local _DATE="$(date --iso-8601=seconds)"
    local _LOGS_MESSAGE="[${_DATE}]  ${_LEVEL} ${_MESSAGE}"
    echo -e "${_LOGS_MESSAGE}"
}

function _GET_OPTS
{
    local _SHORT_OPTS="u:d:e:p:h";
    local _OPTS=$(getopt \
        -o "${_SHORT_OPTS}" \
        -n "${_SCRIPT_NAME}" -- "${@}")

    eval set -- "${_OPTS}"

    while true ; do
        case "${1}" in
            -u)
                _URL_OPT=${2}
                shift 2
                ;;
            -d)
                _DOCUMENTROOT_OPT=${2}
                shift 2
                ;;
            -e)
                _ENTRYPOINT_OPT=${2}
                shift 2
                ;;
            -p)
                _PUBLICDIR_OPT=${2}
                shift 2
                ;;
            -h|--help)
                _USAGE
                shift
                ;;
            --) shift ; break ;;
        esac
    done
}

function _CHECK_OPTS
{
    if [ -z "${_DOCUMENTROOT_OPT}" ]
    then
        _LOGS "ERROR" "documentroot cannot be empty"
        exit 1
    fi
    if [ -z "${_URL_OPT}" ]
    then
        _LOGS "ERROR" "website_url cannot be empty"
        exit 1
    fi
    if [ -z "${_ENTRYPOINT_OPT}" ]
    then
        _LOGS "ERROR" "entrypoint cannot be empty"
        exit 1
    fi
    if [ -z "${_PUBLICDIR_OPT}" ]
    then
        _LOGS "ERROR" "publicdir cannot be empty"
        exit 1
    fi

    if [ -z "${HOME}" ]
    then
        _LOGS "ERROR" "home env var empty stopping"
        exit 1
    fi
}

function _LOAD_ENV
{
    source /etc/ovhconfig.bashrc
    passengerConfig
}

function _PRINT_ENV
{
    cat << EOF
==============================================================
OVH_APP_ENGINE=${OVH_APP_ENGINE}
OVH_APP_ENGINE_VERSION=${OVH_APP_ENGINE_VERSION}
OVH_ENVIRONMENT=${OVH_ENVIRONMENT}
PATH=${PATH}
==============================================================
EOF
}

function _BUILDING
{
    _LOGS "INFO" "building static files"
    cd "${HOME}"/.powerworkflow
    npm install
    # npx eleventy --output="${HOME}"/.powerworkflow/ovhstaticfiles
}

function _REMOVING_OLD_DOCUMENTROOT
{
    _LOGS "INFO" "removing old documentroot"
    rm -rf "${HOME:?}"/"${_DOCUMENTROOT_OPT}"
}

function _CREATING_DOCUMENTROOT
{
    _LOGS "INFO" "creating documentroot"
    mkdir -p "${HOME}"/"${_DOCUMENTROOT_OPT}"
}

function _MOVE_BUILD_FILES
{
    _LOGS "INFO" "moving build files to publicdir"
    # mkdir -p "${HOME}"/"${_DOCUMENTROOT_OPT}"/"${_PUBLICDIR_OPT}"
    # rm -rf "${HOME:?}"/"${_DOCUMENTROOT_OPT}"/"${_PUBLICDIR_OPT}"
    # mv "${HOME}"/.powerworkflow/ovhstaticfiles "${HOME}"/"${_DOCUMENTROOT_OPT}"/"${_PUBLICDIR_OPT}"
}

function _INSTALL_EXPRESS
{
    cd "${HOME}"/"${_DOCUMENTROOT_OPT}"
    npm install express
}

function _CREATING_ENTRYPOINT
{
    _LOGS "INFO" "creating entrypoint"
    # cat << EOF > "${HOME}"/"${_DOCUMENTROOT_OPT}"/"${_ENTRYPOINT_OPT}"
# var express = require('express');
# var app = express();
# app.use('/', express.static(__dirname + '/${_PUBLICDIR_OPT}'));
  
# app.listen();
# EOF
}

function _RESTARTING
{
    _LOGS "INFO" "restarting"
    mkdir -p "${HOME}"/"${_DOCUMENTROOT_OPT}"/tmp
    touch "${HOME}"/"${_DOCUMENTROOT_OPT}"/tmp/restart.txt
}

function _SLEEPING
{
    _LOGS "INFO" "wait 30s for NFS file propagation"
    sleep 30
}

### MAIN
set -e
set -o pipefail
_SCRIPT_NAME=$(basename "${0}")
_GET_OPTS "${@}"
_CHECK_OPTS
_LOAD_ENV
_PRINT_ENV
_BUILDING
_REMOVING_OLD_DOCUMENTROOT
_CREATING_DOCUMENTROOT
_MOVE_BUILD_FILES
_INSTALL_EXPRESS
_CREATING_ENTRYPOINT
_RESTARTING
_SLEEPING
_LOGS "INFO" "job is done"