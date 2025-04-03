FROM debian:bullseye-slim

# Install dependencies (including gosu)
RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    libvirt-clients \
    libvirt-dev \
    && rm -rf /var/lib/apt/lists/*
    RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    # Libvirt client tools (to connect to remote host)
    libvirt-clients \
    # CloudInit ISO generation (fixes "mkisofs" error)
    genisoimage \
    # SSH client for remote provisioning/authentication
    openssh-client \
    # QEMU utilities (for disk image manipulation)
    qemu-utils \
    # XML/XSLT processing (if using Libvirt XML transformations)
    xsltproc \
    # gosu for switching to the non-root user
    gosu \
    # Cleanup
    && rm -rf /var/lib/apt/lists/*

# Install Terraform
ENV TERRAFORM_VERSION=1.11.3
RUN curl -LO "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" \
    && unzip "terraform_${TERRAFORM_VERSION}_linux_amd64.zip" -d /usr/local/bin \
    && rm "terraform_${TERRAFORM_VERSION}_linux_amd64.zip"

# Create non-root user/group
ARG USER_ID=1000
ARG GROUP_ID=1000
RUN groupadd -g ${GROUP_ID} tfuser \
    && useradd -u ${USER_ID} -g tfuser -d /home/tfuser -m tfuser

# Set working directory and permissions
WORKDIR /app
RUN chown tfuser:tfuser /app

# Entrypoint to drop root privileges with gosu
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

# Default command
CMD ["terraform", "--help"]