#!/bin/sh
set -e

# Error message and exit for missing environment variable
fatal() {
		cat << EndOfMessage
###############################################################################
!!!!!!!!!! FATAL ERROR !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
###############################################################################
			The variable with the name '$1' is unset.
			Please specify a value in this container environment using
			-e in docker run or the environment section in Docker Compose.
###############################################################################
EndOfMessage
		exit 1
}

# Check the presence of all runtime variables
[ ! -z ${TRANSMART_API_SERVER_URL+x} ] || fatal 'TRANSMART_API_SERVER_URL'
[ ! -z ${GB_BACKEND_URL+x} ] || fatal 'GB_BACKEND_URL'
[ ! -z ${KEYCLOAK_SERVER_URL+x} ] || fatal 'KEYCLOAK_SERVER_URL'
[ ! -z ${KEYCLOAK_REALM+x} ] || fatal 'KEYCLOAK_REALM'
[ ! -z ${KEYCLOAK_CLIENT_ID+x} ] || fatal 'KEYCLOAK_CLIENT_ID'
[ ! -z ${TRANSMART_PACKER_URL+x} ] || fatal 'TRANSMART_PACKER_URL'


# Apply configuration from environment
envsubst < /usr/share/nginx/html/config.template.json \
         > /usr/share/nginx/html/app/config/config.default.json

echo "${TRANSMART_API_SERVER_URL}"

exec nginx -g 'daemon off;'
