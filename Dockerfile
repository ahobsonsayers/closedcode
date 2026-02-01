FROM ubuntu:latest

ARG OPENCODE_VERSION=1.1.48

ENV TZ=UTC

# Install apt packages
RUN apt-get update && \
    apt-get install -y \
    build-essential \
    ca-certificates \
    coreutils \
    curl \
    findutils \
    git \
    grep \
    jq \
    openssh-client \
    sed \
    sudo \
    unzip \
    util-linux \
    wget \
    zip && \
    rm -rf /var/lib/apt/lists/*

# Remove ubuntu  user and home
RUN rm -rf /root && \
    userdel --remove ubuntu

# Create opencode user and home
# User will have root access via sudo
RUN useradd opencode --uid 1000 --home-dir /home/opencode --create-home && \
    echo "opencode ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/opencode && \
    chmod 0440 /etc/sudoers.d/opencode

USER opencode
ENV HOME=/home/opencode

# Install homebrew
RUN NONINTERACTIVE=1 && \
    curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | bash

# Set required homebrew envs
ENV HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
ENV HOMEBREW_CELLAR="/home/linuxbrew/.linuxbrew/Cellar"
ENV HOMEBREW_REPOSITORY="/home/linuxbrew/.linuxbrew/Homebrew"
ENV PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin${PATH+:$PATH}"

# Install brew packages
RUN brew install \
    gh \
    node

# Install bun
RUN curl -fsSL https://bun.sh/install | bash
ENV PATH=$HOME/.bun/bin:$PATH

# Install opencode
RUN bun install -g opencode-ai@$OPENCODE_VERSION

ENV OPENCODE_CONFIG='{ \
  "$schema": "https://opencode.ai/config.json", \
  "autoupdate": false \
}'

# Add entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN sudo chmod +x /entrypoint.sh

# Setup persistence
RUN mkdir -p /home/opencode/.config/opencode && \
    mkdir -p /home/opencode/.local/share/opencode

VOLUME /home/opencode/.config/opencode # Persist opencode config
VOLUME /home/opencode/.local/share/opencode # Persist opencode data

WORKDIR "$HOME/workspace"

ENTRYPOINT ["/entrypoint.sh", "opencode"]
