#!/bin/bash

. base-functions.sh
default_pass=123456

function check_openssl() {
    if ! __cmd_exists "openssl"; then
        __msg_error " install openssl and run again"
    else
        __msg_info "check openssl version"
    fi
}

function check_keytool() {
    if ! __cmd_exists "keytool"; then
        __msg_error " install keytool and run again"
    else
        __msg_info "check keytool version"
    fi
}

#########################
# PEM keystore functions
#
#########################
function _pem_extract() {
    local file=$1
    if __file_exist "$file" ; then
        local tmp_dir="$file"_ext
        mkdir $tmp_dir
        gawk -v tmp_dir=$tmp_dir 'BEGIN {c=0;} /BEGIN CER/ {c++} {print > "./" tmp_dir "/cert." c ".pem"}' < $file
        if __file_exist "$tmp_dir/cert.0.pem" ; then
            rm -f "$tmp_dir/cert.0.pem"
        fi
        echo "$(realpath $tmp_dir)"
    fi
}
function _pem_ls() {
    local file=$1
    
    if __file_exist "$file" ; then
        local tmp_dir="$file"_tmp
        mkdir $tmp_dir
        gawk -v tmp_dir=$tmp_dir 'BEGIN {c=0;} /BEGIN CER/ {c++} {print > "./" tmp_dir "/cert." c ".pem"}' < $file
        
        for cert in $(ls $tmp_dir);
        do
            __msg_delimiter
            local IFS=$'\n'
            for data1 in $(openssl x509 -in "./$tmp_dir/$cert" -inform PEM -noout -issuer -subject -dates -ext keyUsage.extendedKeyUsage );
            do
                echo $data1
            done
            __msg_delimiter
        done
        rm -rf $tmp_dir
    fi
    
}
#########################
# Java keystore functions
#
#########################
function _jks_ls()
{     local file=$1
    
    if __file_exist "$file" ; then
        keytool -list -keystore $file
    fi
    
}
function _jks_extract()
{
    local file=$1
    if __file_exist "$file" ; then
        local tmp_dir="$file"_ext
        mkdir $tmp_dir
        keytool -list -keystore $file -rfc | gawk -v tmp_dir=$tmp_dir 'BEGIN {c=0;} /Alias/ {c++} {print > "./" tmp_dir "/cert." c ".tmp"}' < $file
        
        for cert in $( ls "./$tmp_dir/*.tmp");
        do
            a=$(grep Alias "./$tmp_dir/$cert")
            alias=${a:12}
            __log_info "Extract Alias $alias"
            if [[ -z "$alias" ]]; then
                mkdir -p "./$tmp_dir/$alias"
                gawk -v t_dir="./$tmp_dir/$alias" 'BEGIN {c=0;} /BEGIN CER/ {c++} {print > "./" t_dir "/cert." c ".pem"}' < "./$tmp_dir/$cert"
                #if __file_exist "./$tmp_dir/cert.0.pem" ; then
                #    rm -f ./$tmp_dir/cert.0.tmp
                #fi
            fi
            rm -f "./$tmp_dir/$cert"
        done
        echo "$(realpath $tmp_dir)"
    fi
}
function _jks_import(){
    local container=$1
    local dest_file=$2
    local src_pass=$default_pass
    local dest_pass=$default_pass
    keytool -importkeystore \
    -srcstorepass $src_pass \
    -srckeystore $container.jks \
    -destkeystore $dest_file \
    -destalias "$container" \
    -alias "$container" \
    -deststoretype PKCS12 \
    -deststorepass $dest_pass \
    -destkeypass $dest_pass
}
#########################
# PKCS 12 keystore functions
#
#########################
function _pkcs_ls() {
    local file=$1
    
}
#########################
# Convert keystore functions
#
#########################
function _pkcs2pem(){
    local container=$1
    local dest_pass=$default_pass
    
    openssl pkcs12 -in $container.p12 -nokeys -password pass:$dest_pass -out $container.crt.pem
    openssl pkcs12 -in $container.p12 -nodes -nocerts -password pass:$dest_pass -out $container.key.pem
}
function _pem2pkcs(){
    local cert_file=$1
    local key_file=$2
    local container=$3
    local dest_pass=$default_pass
    
    openssl pkcs12 -export - out $container.p12 -inkey $key_file -in $cert_file -password pass:$dest_pass
    
}

function _pkcs2jks(){
    local container=$1
    local src_pass=$default_pass
    local dest_pass=$default_pass
    keytool -importkeystore \
    -srcstorepass $src_pass \
    -srckeystore $container.p12 \
    -destkeystore $container.jks \
    -destalias "$container" \
    -alias "1" \
    -deststoretype PKCS12 \
    -deststorepass $dest_pass \
    -destkeypass $dest_pass
}

function _jks2pkcs(){
    local jks_file=$1
    local container=$2
    local src_pass=$default_pass
    local dest_pass=$default_pass
    keytool -importkeystore \
    -srcstorepass $src_pass \
    -srckeystore $jks_file \
    -srcalias $container \
    -destkeystore $container.p12 \
    -deststoretype PKCS12 \
    -deststorepass $dest_pass \
    -destkeypass $dest_pass
}

