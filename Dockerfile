FROM docker.io/certbot/dns-route53:latest

RUN apk add --update coreutils curl jq bash && \
    curl -Lo /usr/local/bin/kubectl "https://dl.k8s.io/release/v1.24.0/bin/linux/amd64/kubectl" && \
    chmod +x /usr/local/bin/kubectl

COPY run.sh /usr/local/bin/run.sh

ENTRYPOINT [ "/usr/local/bin/run.sh" ]
