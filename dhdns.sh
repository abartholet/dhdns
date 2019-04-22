#!/bin/bash
IFS=$'\t'

DHAPI_URL="https://api.dreamhost.com/"
DH_KEY=""
RECORD=""

LOG_FILE="/tmp/dhdns.log"
echo "" > ${LOG_FILE}

DH_IP=""
if [ ! -z "${DH_KEY}" ]; then
    MY_IP=$(curl -s "https://api.ipify.org")

    while IFS=$'\t' read -r line; do
        DH_RECORD=$(echo "${line}" | cut -d$'\t' -f3)
        if [ "${DH_RECORD}" == "${RECORD}" ]; then
            DH_IP=$(echo "${line}" | cut -d$'\t' -f5)
        fi
    done < <(curl -s "${DHAPI_URL}?key=${DH_KEY}&cmd=dns-list_records")

    if [ -z "${DH_IP}" ]; then
        curl -s "${DHAPI_URL}?key=${DH_KEY}&cmd=dns-add_record&record=${RECORD}&type=A&value=${MY_IP}" >> ${LOG_FILE}
    elif [ ! -z "${DH_IP}" ] && [ "${MY_IP}" != "${DH_IP}" ]; then
        curl -s "${DHAPI_URL}?key=${DH_KEY}&cmd=dns-remove_record&record=${RECORD}&type=A&value=${DH_IP}" >> ${LOG_FILE}
        curl -s "${DHAPI_URL}?key=${DH_KEY}&cmd=dns-add_record&record=${RECORD}&type=A&value=${MY_IP}" >> ${LOG_FILE}
    fi
else
    echo "DHDNS not configured."
fi
