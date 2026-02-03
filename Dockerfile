FROM ubuntu:latest

ARG OPENCODE_VERSION=1.1.48

ENV TZ=UTC

# Install apt packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    coreutils \
    curl \
    findutils \
    gh \
    git \
    grep \
    jq \
    openssh-client \
    sed \
    sudo \
    tar \
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

# Install homebrew (using tar for small size)
RUN sudo mkdir -p /home/linuxbrew/.linuxbrew && \
    sudo chown -R "$(id -u):$(id -g)" /home/linuxbrew/.linuxbrew && \
    curl -L https://github.com/Homebrew/brew/tarball/main | \
    tar xz --strip-components 1 -C /home/linuxbrew/.linuxbrew

# Set required homebrew envs
ENV HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
ENV HOMEBREW_CELLAR="/home/linuxbrew/.linuxbrew/Cellar"
ENV HOMEBREW_REPOSITORY="/home/linuxbrew/.linuxbrew/Homebrew"
ENV PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$PATH"

# Install bun
RUN curl -fsSL https://bun.sh/install | bash
ENV PATH=$HOME/.bun/bin:$PATH

# Install opencode
# force and no-cahce are required to prevent bun issues on arm
RUN bun install --global --force --no-cache opencode-ai@$OPENCODE_VERSION

ENV OPENCODE_CONFIG='{ \
    "$schema": "https://opencode.ai/config.json", \
    "autoupdate": false \
    }'

# Add entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN sudo chmod +x /entrypoint.sh

# Setup persistence
RUN mkdir -p "$HOME/.config/opencode" && \
    mkdir -p "$HOME/.local/share/opencode"

# Persist opencode config
VOLUME "$HOME/.config/opencode"

# Persist opencode data
VOLUME "$HOME/.local/share/opencode"

WORKDIR "$HOME/workspace"

ENTRYPOINT ["/entrypoint.sh", "bun", "run", "opencode"]
