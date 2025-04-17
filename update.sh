#!/bin/bash

DOMAIN_FILE_PATH="neray-domain.dat"
DOMAIN_UPLOAD_NAME="E6qNpktkBo5a9JV.dat"

IP_FILE_PATH="neray-ip.dat"
IP_UPLOAD_NAME="r57s4X2nJPn1B1E.dat"

BIN_DIR="$(pwd)/bin"

clean_up() {
    if [[ -f ${DOMAIN_FILE_PATH} ]]; then
        rm ${DOMAIN_FILE_PATH}
    fi

    if [[ -f ${IP_FILE_PATH} ]]; then
        rm ${IP_FILE_PATH}
    fi
}

install_command() {
    if [[ ! -d ${BIN_DIR} ]]; then
        GOBIN=${BIN_DIR} go install -v github.com/v2fly/domain-list-community@latest
        GOBIN=${BIN_DIR} go install -v github.com/Loyalsoldier/geoip@latest
    fi
}

generate_dat_files() {
   ${BIN_DIR}/domain-list-community --outputname=${DOMAIN_FILE_PATH} --datapath=./data-domain
   ${BIN_DIR}/geoip convert -c geoip-config.json
}

upload_dat_files() {
    local UPLOAD_PATH="home-vpn.neray.ru:/opt/www/sub.neray.ru"

    scp ${DOMAIN_FILE_PATH} ${UPLOAD_PATH}/${DOMAIN_UPLOAD_NAME}
    scp ${IP_FILE_PATH} ${UPLOAD_PATH}/${IP_UPLOAD_NAME}
}


clean_up
install_command

generate_dat_files

# upload_dat_files

clean_up
