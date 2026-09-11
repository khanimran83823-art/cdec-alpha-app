FROM gcr.io/kaniko-project/executor:v1.23.2-debug AS kaniko
FROM jenkins/inbound-agent:latest

USER root

# AWS CLI, kubectl, aur Maven install karein
RUN apt-get update && apt-get install -y \
    curl unzip ca-certificates maven \
    && curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip && ./aws/install && rm -rf awscliv2.zip aws \
    && curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
    && install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl \
    && rm -rf /var/lib/apt/lists/*

# Kaniko binaries copy karein
COPY --from=kaniko /kaniko /kaniko
ENV PATH=$PATH:/kaniko
ENV SSL_CERT_DIR=/kaniko/ssl/certs

USER jenkins
