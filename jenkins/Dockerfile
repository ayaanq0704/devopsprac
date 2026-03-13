FROM jenkins/jenkins:lts-jdk17

USER root

RUN apt-get update && apt-get install -y \
    curl \
    wget \
    unzip \
    gnupg \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install Terraform
RUN wget -q https://releases.hashicorp.com/terraform/1.6.6/terraform_1.6.6_linux_amd64.zip \
    && unzip terraform_1.6.6_linux_amd64.zip \
    && mv terraform /usr/local/bin/ \
    && rm terraform_1.6.6_linux_amd64.zip

# Install Trivy
RUN wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key \
    | gpg --dearmor | tee /usr/share/keyrings/trivy.gpg > /dev/null \
    && echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb generic main" \
    | tee /etc/apt/sources.list.d/trivy.list \
    && apt-get update \
    && apt-get install -y trivy

USER jenkins