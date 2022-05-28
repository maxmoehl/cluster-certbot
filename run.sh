#!/usr/bin/env ash

set -e

function log() {
  echo "[$(date)] ${1}"
}

if [[ -z "${EMAIL}" ]]; then
  log "EMAIL is empty"
  exit 1
fi
if [[ -z "${DOMAIN}" ]]; then
  log "DOMAIN is empty"
  exit 1
fi
if [[ -z "${NAMESPACE}" ]]; then
  log "NAMESPACE is empty"
  exit 1
fi

log "requesting certificate"
certbot \
  certonly \
  -n \
  --agree-tos \
  -m "${EMAIL}" \
  --dns-route53 \
  --dns-route53-propagation-seconds 30 \
  -d "${DOMAIN}"

# certbot removes '*.' from the beginning of the domain when writing the certs
if [[ "${DOMAIN:0:2}" == '*.' ]]; then
  DOMAIN="${DOMAIN:2}"
fi

log "writing certificate to kubernetes secret ${NAMESPACE}/${SECRET_NAME}"
JSON_PATCH="$(printf '{
  "data": {
    "tls.crt": "%s",
    "tls.key": "%s"
  }
}' "$(base64 -w0 "/etc/letsencrypt/live/${DOMAIN}/fullchain.pem")" "$(base64 -w0 "/etc/letsencrypt/live/${DOMAIN}/privkey.pem")")"
JSON_PATCH="$(echo "${JSON_PATCH}" | jq -c '.')"
kubectl -n "${NAMESPACE}" patch secret "${SECRET_NAME}" --patch "${JSON_PATCH}"
