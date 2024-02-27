#!/usr/bin/env bash

# Get prerequisite information
if [ -z ${TF_WORKSPACE} ]; then
  echo "Error: cannot determine value of TF_WORKSPACE environment variable"; exit 99
fi

SUBSCRIPTION=`sed -n 's;^subscription_id \+= \+\"\(.*\)\";\1;p' ${TF_WORKSPACE}.azurerm.tfbackend`
if [ -z ${SUBSCRIPTION} ]; then
  echo "Error: cannot determine value of subscription_id from ${TF_WORKSPACE}.azurerm.tfbackend"; exit 99
fi

BACKEND_STORAGE_NAME=`sed -n 's;^storage_account_name \+= \+\"\(.*\)\";\1;p' ${TF_WORKSPACE}.azurerm.tfbackend`
if [ -z ${BACKEND_STORAGE_NAME} ]; then
  echo "Error: cannot determine value of storage_account_name from ${TF_WORKSPACE}.azurerm.tfbackend"; exit 99
fi

BACKEND_STORAGE_CONTAINER=`sed -n 's;^container_name \+= \+\"\(.*\)\";\1;p' ${TF_WORKSPACE}.azurerm.tfbackend`
if [ -z ${BACKEND_STORAGE_CONTAINER} ]; then
  echo "Error: cannot determine value of container_name from ${TF_WORKSPACE}.azurerm.tfbackend"; exit 99
fi

# Get SAS token
END=`date -u -d "120 minutes" '+%Y-%m-%dT%H:%MZ'`
TOKEN=`az storage container generate-sas --subscription ${SUBSCRIPTION} --account-name ${BACKEND_STORAGE_NAME} --name ${BACKEND_STORAGE_CONTAINER} --permissions acdlrw --https-only --expiry ${END} --output tsv 2>/dev/null`

# Define SAS token in environment variables
if [ -z ${GITHUB_ENV} ]; then
  export ARM_SAS_TOKEN=${TOKEN}
else
  echo "ARM_SAS_TOKEN=${TOKEN}" >> $GITHUB_ENV
fi