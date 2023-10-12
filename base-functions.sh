#!/usr/bin/env bash
#
# default functions for scripts
#
################################################################################
base_functions_ver=3
red="\e[31m"
green="\e[32m"
endcolors="\e[0m"
light_cyan="\e[96m"
light_red="\e[91m"
delimiter_str="="
delimiter_len=79
logger_time_fmt='%Y-%m-%dT%H:%M:%S%z'
logger_destination=""
__msg_delimiter=""

function __check_var() {
    local var_name=$1
    local default_value=$2
    if [[ -z ${!var_name+x} ]]; then
        _log_debug "var ${var_name} is unset, setting to default"
        declare ${var_name}=${default_value}
    else
        _log_debug "var is set to '${!var_name}'"
    fi
    _log_debug " ${var_name} = ${!var_name}"
}
function __set_msg_delimiter() {
    local result
    local i
    for i in $(seq 1 $delimiter_len); do  result+="$delimiter_str"; done
    __msg_delimiter=$result
    #echo $result
}
function _msg_delimiter() {
    echo $__msg_delimiter
}

function _logger_start(){
    if [[ $# -gt 0 ]] ; then
        logger_destination=$1
    fi
    #echo dest "$logger_destination"
    if [[ "$logger_destination" == "" ]]; then
        exec 3> /dev/null
    else
        exec 3<>$logger_destination
    fi
}
function _logger_stop(){
    exec 3>&-
}
function __logger_date_time() {
    echo $( date +${logger_time_fmt})
}

function _log_error() {
    if [[ "${LOGLEVEL}" == "ERROR" ]] || [[ "${LOGLEVEL}" == "INFO" ]] || [[ "${LOGLEVEL}" == "DEBUG" ]]; then
        echo -e "[$(__logger_date_time) "ERROR"]: $*" >&3
    fi
}

function _log_info() {
    if  [[ "${LOGLEVEL}" == "INFO" ]] || [[ "${LOGLEVEL}" == "DEBUG" ]]; then
        echo -e "[$(__logger_date_time) "INFO" ]: $*" >&3
    fi
}

function _log_debug() {
    if  [[ "${LOGLEVEL}" == "DEBUG" ]]; then
        echo -e "[$(__logger_date_time) "DEBUG"]: $*" >&3
    fi
}

function _msg_error() {
    printf "${light_red}%s${endcolors}\\n" "${*}"
    _log_error "${*}"
}
function _msg_info() {
    printf "${light_cyan}%s${endcolors}\\n" "${*}"
    _log_info "${*}"
}

function __cmd_exists()
{
    command -v "$1" >/dev/null 2>&1
    if [[ $? -eq 0 ]]; then
        _log_info "$1 found"
        return 0
    else
        _log_error "$1 not found"
        return 1
    fi
}
function __file_exist()
{
    if [[ -z "$1" ]]; then
        _log_error "filename is empty"
        return 1
    fi
    if ! [[ -e $1 ]]; then
        _log_error "file $1 not found"
        return 1
    fi
}

function _str_trim()
{
    local trimmed="$1"
    
    # Strip leading space.
    trimmed="${trimmed## }"
    # Strip trailing space.
    trimmed="${trimmed%% }"
    
    echo "$trimmed"
}

_logger_start 
__set_msg_delimiter