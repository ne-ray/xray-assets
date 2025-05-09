#!/bin/bash

export CURRENT_DIR=$(dirname "$(realpath $0)")
export CURRENT_DIR_RELATIVE="$(perl -le 'use File::Spec; print File::Spec->abs2rel(@ARGV)' $(dirname $0) $(pwd))"

export DOMAIN_FILE_NAME="neray-domain.dat"
export DOMAIN_FILE_PATH="${CURRENT_DIR}/${DOMAIN_FILE_NAME}"
export DOMAIN_FILE_PATH_RELATIVE="${CURRENT_DIR_RELATIVE}/${DOMAIN_FILE_NAME}"
export DOMAIN_UPLOAD_NAME="E6qNpktkBo5a9JV.dat"
export DOMAIN_FULL_FILE_NAME="neray-domain-full.dat"
export DOMAIN_FULL_FILE_PATH="${CURRENT_DIR}/${DOMAIN_FULL_FILE_NAME}"
export DOMAIN_FULL_FILE_PATH_RELATIVE="${CURRENT_DIR_RELATIVE}/${DOMAIN_FULL_FILE_NAME}"
export DOMAIN_FULL_UPLOAD_NAME="E6qNpktkBo5a9JV_full.dat"

export IP_FILE_NAME="neray-ip.dat"
export IP_FILE_PATH="${CURRENT_DIR}/${IP_FILE_NAME}"
export IP_UPLOAD_NAME="r57s4X2nJPn1B1E.dat"
export IP_FULL_FILE_NAME="neray-ip-full.dat"
export IP_FULL_FILE_PATH="${CURRENT_DIR}/${IP_FULL_FILE_NAME}"
export IP_FULL_UPLOAD_NAME="r57s4X2nJPn1B1E_full.dat"

export SUBS_FILE_PATH="${CURRENT_DIR}/subs.conf"
export SUBS_UPLOAD_NAME="uqa1ec4mjsb2yl22hz6usqgdl034hmnp.conf"

export INSTALL_GUIDE_FILE_PATH="${CURRENT_DIR}/vpn-install.html"
export INSTALL_GUIDE_UPLOAD_NAME="bXqAwOoSWFp2YZZe.html"

export V2RAYNG_FILE_PATH="${CURRENT_DIR}/v2rayNG.zip"
export V2RAYNG_UPLOAD_NAME="doKrbqQ3QsdIJlDd.zip"

export BIN_DIR="${CURRENT_DIR}/bin"
export BUILD_LINUX_DIR="${CURRENT_DIR}/build_linux"
export BIN_LINUX_DIR="${BUILD_LINUX_DIR}/bin/linux_amd64"

export RULESET_DIR="${CURRENT_DIR}/source_ruleset"
export RULESET_DLC_DIR="${RULESET_DIR}/dlc"
export RULESET_GEOIP_PATH="${RULESET_DIR}/geoip.dat"

export RULESET_SOURCE_GEOIP_DIR="${CURRENT_DIR}/data-ip"
export RULESET_SOURCE_GEOSITE_DIR="${CURRENT_DIR}/data-domain"

UPLOAD_SCP_HOSTNAME="home-vpn.neray.ru:"
UPLOAD_WWW_PATH="/opt/www/sub.neray.ru"
UPLOAD_AUTOUPDATE_PATH="/opt/vpn-autoupdate-config"

clean_up() {
    if [[ -f ${DOMAIN_FILE_PATH} ]]; then
        rm ${DOMAIN_FILE_PATH}
    fi

    if [[ -f ${DOMAIN_FULL_FILE_PATH} ]]; then
        rm ${DOMAIN_FULL_FILE_PATH}
    fi

    if [[ -f ${IP_FILE_PATH} ]]; then
        rm ${IP_FILE_PATH}
    fi

    if [[ -f ${IP_FULL_FILE_PATH} ]]; then
        rm ${IP_FULL_FILE_PATH}
    fi

    if ls ${CURRENT_DIR}/autogen-*-config.json 1> /dev/null 2>&1; then
        rm ${CURRENT_DIR}/autogen-*-config.json
    fi

    if [[ -d "${BUILD_LINUX_DIR}/pkg" ]]; then
        rm -rf ${BUILD_LINUX_DIR}/pkg
    fi

    if [[ -d "${RULESET_DIR}" ]]; then
        rm -rf ${RULESET_DIR}
    fi
}

install_commands() {
    if [[ ! -d ${BIN_DIR} ]]; then
        GOBIN=${BIN_DIR} go install -v github.com/v2fly/domain-list-community@latest
        GOBIN=${BIN_DIR} go install -v github.com/Loyalsoldier/geoip@latest
    fi
}

install_commands_linux() {
    if [[ ! -d ${BIN_LINUX_DIR} ]]; then
        GOPATH=${BUILD_LINUX_DIR} GOOS=linux GOARCH=amd64 go install -v github.com/v2fly/domain-list-community@latest
        GOPATH=${BUILD_LINUX_DIR} GOOS=linux GOARCH=amd64 go install -v github.com/Loyalsoldier/geoip@latest
    fi
}

autogen_geoip_config() {
    local FILENAME=$1
    local FILEPATH="${CURRENT_DIR}/$FILENAME"
    local AUTOGENFILEPATH="${CURRENT_DIR}/autogen-${FILENAME}"

    echo $(envsubst < ${FILEPATH}) > ${AUTOGENFILEPATH}
}

ruleset_ext_generate() {
    local GEOIP_CONFIG="geoip-ext-config.json"

    cp ${RULESET_SOURCE_GEOSITE_DIR}/proxy-neray-ru ${RULESET_SOURCE_GEOSITE_DIR}/direct
    ${BIN_DIR}/domain-list-community --outputname=${DOMAIN_FILE_PATH_RELATIVE} --datapath=${RULESET_SOURCE_GEOSITE_DIR}
    rm ${RULESET_SOURCE_GEOSITE_DIR}/direct
    autogen_geoip_config $GEOIP_CONFIG
    ${BIN_DIR}/geoip convert -c ${CURRENT_DIR}/autogen-${GEOIP_CONFIG}
}

ruleset_full_download() {
    mkdir ${RULESET_DIR}
    git clone --depth 1 https://github.com/v2fly/domain-list-community.git ${RULESET_DLC_DIR}
    wget https://github.com/v2fly/geoip/releases/latest/download/geoip.dat -O ${RULESET_GEOIP_PATH}
}

ruleset_full_generate() {
    local GEOIP_CONFIG="geoip-full-config.json"

    cp ${RULESET_SOURCE_GEOSITE_DIR}/* ${RULESET_DLC_DIR}/data/
    ${BIN_DIR}/domain-list-community --outputname=${DOMAIN_FULL_FILE_PATH_RELATIVE} --datapath=${RULESET_DLC_DIR}/data
    autogen_geoip_config $GEOIP_CONFIG
    ${BIN_DIR}/geoip convert -c ${CURRENT_DIR}/autogen-${GEOIP_CONFIG}
}

scp_upload() {
    $1 "scp" ${UPLOAD_SCP_HOSTNAME}
}

upload_guide() {
    $1 ${INSTALL_GUIDE_FILE_PATH} $2${UPLOAD_WWW_PATH}/${INSTALL_GUIDE_UPLOAD_NAME}
    $1 ${V2RAYNG_FILE_PATH} $2${UPLOAD_WWW_PATH}/${V2RAYNG_UPLOAD_NAME}
    $1 -r ${CURRENT_DIR}/foxray-ios-img $2${UPLOAD_WWW_PATH}/
    $1 -r ${CURRENT_DIR}/v2ray-ng-img $2${UPLOAD_WWW_PATH}/
    $1 ${CURRENT_DIR}/foxray-redirect.html $2${UPLOAD_WWW_PATH}/foxray-redirect.html
}

upload_subs() {
    $1 ${SUBS_FILE_PATH} $2${UPLOAD_WWW_PATH}/${SUBS_UPLOAD_NAME}
}

upload_ruleset_ext() {
    $1 ${DOMAIN_FILE_PATH} $2${UPLOAD_WWW_PATH}/${DOMAIN_UPLOAD_NAME}
    $1 ${IP_FILE_PATH} $2${UPLOAD_WWW_PATH}/${IP_UPLOAD_NAME}
}

upload_ruleset_full() {
    $1 ${DOMAIN_FULL_FILE_PATH} $2${UPLOAD_WWW_PATH}/${DOMAIN_FULL_UPLOAD_NAME}
    $1 ${IP_FULL_FILE_PATH} $2${UPLOAD_WWW_PATH}/${IP_FULL_UPLOAD_NAME}
}

upload_ruleset_source() {
    $1 -r ${RULESET_SOURCE_GEOSITE_DIR} $2${UPLOAD_AUTOUPDATE_PATH}
    $1 -r ${RULESET_SOURCE_GEOIP_DIR} $2${UPLOAD_AUTOUPDATE_PATH}
    $1 ${CURRENT_DIR}/geoip-*-config.json $2${UPLOAD_AUTOUPDATE_PATH}/
}

##############################
###### running function ######
##############################

install() {
    clean_up
    install_commands
    install_commands_linux
}

build_ruleset() {
    clean_up
    ruleset_ext_generate
    ruleset_full_download
    ruleset_full_generate
}

scp_upload_www_full() {
    scp_upload "upload_guide"
    scp_upload "upload_subs"
    scp_upload "upload_ruleset_ext"
    scp_upload "upload_ruleset_full"

    clean_up
}

scp_autoupdate_full() {
    scp ${BUILD_LINUX_DIR}/bin/linux_amd64/* ${UPLOAD_SCP_HOSTNAME}${UPLOAD_AUTOUPDATE_PATH}/bin
    scp ${CURRENT_DIR}/update.sh ${UPLOAD_SCP_HOSTNAME}${UPLOAD_AUTOUPDATE_PATH}
    scp_upload "upload_ruleset_source"
}

update_ruleset_full() {
    clean_up
    ruleset_full_download
    ruleset_full_generate
    upload_ruleset_full "cp" ""
    clean_up
}

help() {
    echo "install - arg install bin files for generate ruleset files and other"
    echo "build_ruleset - generate geoip geosite full and simpe version"
    echo "scp_upload_www_full - copy guide subs config and other to remote server"
    echo "scp_autoupdate_full - copy bin config and source geoip / geosite to remote server for autoupdate script"
    echo "update_ruleset_full - run autoupdate script"
}

################
##### RUN ######
################
CMD=$1

if [[ "" == "$CMD" ]]; then
    help
else
    $CMD
fi
