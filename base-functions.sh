#!/usr/bin/env bash
#
# default functions for scripts
#
################################################################################
base_functions_ver=2
red="\e[31m"
green="\e[32m"
endcolors="\e[0m"
light_cyan="\e[96m"
delimiter_str="="
delimiter_len=79

function __check_var() {
    local var_name=$1
    local default_value=$2
    if [[ -z ${!var_name+x} ]]; then
        __log_debug "var ${var_name} is unset, setting to default"
        declare ${var_name}=${default_value}
    else
        __log_debug "var is set to '${!var_name}'"
    fi  
    __log_debug " ${var_name} = ${!var_name}"
    
}

function __msg_delimiter() {
    local result
    local i
    for i in $(seq 1 $delimiter_len); do  result+="$delimiter_str"; done
    echo $result
}

function __log_error() {
    [[ "${LOGLEVEL}" == "ERROR" ]] && echo -e "[$(date +'%Y-%m-%dT%H:%M:%S%z') ${LOGLEVEL}]: $*" >&2
}

function __log_debug() {
    [[ "${LOGLEVEL}" == "DEBUG" ]] && echo -e "[$(date +'%Y-%m-%dT%H:%M:%S%z') ${LOGLEVEL}]: $*"
}

function __log_info() {
    [[ "${LOGLEVEL}" == "INFO" ]] && echo -e "[$(date +'%Y-%m-%dT%H:%M:%S%z') ${LOGLEVEL}]: $*"
}

function __msg_error() {
    printf "${red}!!! %s${endcolors}\\n" "${*}" 1>&2
}
function __msg_info() {
    printf "${light_cyan}___ %s${endcolors}\\n" "${*}" 1>&2
}

function __cmd_exists()
{
    command -v "$1" >/dev/null 2>&1
    if [[ $? -eq 0 ]]; then
        __log_info "$1 found"
        return 0
    else
        __log_error "$1 not found"
        return 1
    fi
}
function __file_exist()
{
    if [[ -z "$1" ]]; then
        __log_error "filename is empty"
        return 1
    fi
    if ! [[ -e $1 ]]; then
        __log_error "file $1 not found"
        return 1
    fi
}

