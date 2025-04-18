#!/bin/bash

DOMAIN_FILE_PATH="neray-domain.dat"
DOMAIN_UPLOAD_NAME="E6qNpktkBo5a9JV.dat"

IP_FILE_PATH="neray-ip.dat"
IP_UPLOAD_NAME="r57s4X2nJPn1B1E.dat"

SUBS_FILE_PATH="subs.conf"
SUBS_UPLOAD_NAME="uqa1ec4mjsb2yl22hz6usqgdl034hmnp.conf"

INSTALL_GUIDE_FILE_PATH="vpn-install.html"
INSTALL_GUIDE_UPLOAD_NAME="bXqAwOoSWFp2YZZe.html"

V2RAYNG_FILE_PATH="v2rayNG.zip"
V2RAYNG_UPLOAD_NAME="doKrbqQ3QsdIJlDd.zip"

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

upload_files() {
    local UPLOAD_PATH="home-vpn.neray.ru:/opt/www/sub.neray.ru"

    scp ${DOMAIN_FILE_PATH} ${UPLOAD_PATH}/${DOMAIN_UPLOAD_NAME}
    scp ${IP_FILE_PATH} ${UPLOAD_PATH}/${IP_UPLOAD_NAME}
    scp ${SUBS_FILE_PATH} ${UPLOAD_PATH}/${SUBS_UPLOAD_NAME}
    scp ${INSTALL_GUIDE_FILE_PATH} ${UPLOAD_PATH}/${INSTALL_GUIDE_UPLOAD_NAME}
    scp ${V2RAYNG_FILE_PATH} ${UPLOAD_PATH}/${V2RAYNG_UPLOAD_NAME}
    scp -r foxray-ios-img ${UPLOAD_PATH}/
    scp foxray-redirect.html ${UPLOAD_PATH}/foxray-redirect.html
}


clean_up
install_command

generate_dat_files

upload_files

clean_up
