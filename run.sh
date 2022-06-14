#!/usr/bin/env bash

set -e

function log() {
  echo "[$(date)] ${1}"
}

if [[ -z "${EMAIL}" ]]; then
  log "EMAIL is empty"
  exit 1
fi
if [[ -z "${NAMESPACE}" ]]; then
  log "NAMESPACE is empty"
  exit 1
fi
if [[ -z "${CERT_NAME}" ]]; then
  log "CERT_NAME is empty"
  exit 1
fi

log "requesting certificate for domains: (${*})"

args=()
for domain in "${@}"; do
  args+=('-d' "${domain}")
done

if [[ "${DRY_RUN:+set}" == "set" ]]; then
  log "dry-run, would execute:
certbot
    certonly
    -n
    --agree-tos
    -m ${EMAIL}
    --dns-route53
    --dns-route53-propagation-seconds 30
    --cert-name ${CERT_NAME}
    ${args[*]}"
  log "exiting"
  exit 0
fi

log "requesting certificate"
certbot \
  certonly \
  -n \
  --agree-tos \
  -m "${EMAIL}" \
  --dns-route53 \
  --dns-route53-propagation-seconds 30 \
  --cert-name "${CERT_NAME}" \
  "${args[@]}"

log "writing certificate to kubernetes secret ${NAMESPACE}/${SECRET_NAME}"
JSON_PATCH="$(printf '{
  "data": {
    "tls.crt": "%s",
    "tls.key": "%s"
  }
}' "$(base64 -w0 "/etc/letsencrypt/live/${CERT_NAME}/fullchain.pem")" "$(base64 -w0 "/etc/letsencrypt/live/${CERT_NAME}/privkey.pem")")"
JSON_PATCH="$(echo "${JSON_PATCH}" | jq -c '.')"
kubectl -n "${NAMESPACE}" patch secret "${SECRET_NAME}" --patch "${JSON_PATCH}"
