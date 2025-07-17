FROM quay.io/helmpack/chart-testing:v3.11.0
LABEL Name=JPetStore Version=0.0.1

# Used to se the HELM working directory
ENV HOME=/tmp

# Install the necessary tools
RUN apk add --no-cache go python3 py3-pip aws-cli jq \
&& go install filippo.io/age/cmd/...@latest \
&& wget -O /usr/local/bin/sops https://github.com/getsops/sops/releases/download/v3.9.0/sops-v3.9.0.linux.amd64 \
&& chmod 700 /usr/local/bin/sops \
&& mkdir -p /tmp/.config/sops/age \
&& helm plugin install https://github.com/jkroepke/helm-secrets --version v4.6.1 \
&& helm plugin install https://github.com/databus23/helm-diff --version v3.9.11 