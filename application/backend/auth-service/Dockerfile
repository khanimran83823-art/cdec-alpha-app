# Stage 1: Kaniko official image se binaries fetch karein
FROM gcr.io/kaniko-project/executor:v1.23.2-debug AS kaniko

# Stage 2: Jenkins Inbound Agent base image
FROM jenkins/inbound-agent:latest

USER root

# 1. AWS CLI, kubectl, aur Maven install karein
RUN apt-get update && apt-get install -y \
    curl unzip ca-certificates maven \
    && curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip && ./aws/install && rm -rf awscliv2.zip aws \
    && curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
    && install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl \
    && rm -rf /var/lib/apt/lists/*

# 2. Kaniko binaries copy karein aur ownership 'jenkins' user ko assign karein
COPY --from=kaniko /kaniko /kaniko
RUN chown -R jenkins:jenkins /kaniko

# 3. PATH & Certificate setup + Symlink for easy execution
ENV PATH="/kaniko:${PATH}"
ENV SSL_CERT_DIR="/kaniko/ssl/certs"
RUN ln -s /kaniko/executor /usr/local/bin/executor

# 4. Jenkins non-root user par switch karein
USER jenkins
