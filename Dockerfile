FROM ubuntu:latest

ARG OPENCODE_VERSION=1.1.48

ENV TZ=UTC

# Install apt packages
RUN  curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && \
    apt-get update && \
    apt-get install -y \
    build-essential \
    ca-certificates \
    coreutils \
    curl \
    findutils \
    gh \
    git \
    grep \
    jq \
    nodejs \
    openssh-client \
    python3 \
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
RUN bun install -g opencode-ai@$OPENCODE_VERSION

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

VOLUME "$HOME/.config/opencode" # Persist opencode config
VOLUME "$HOME/.local/share/opencode" # Persist opencode data

WORKDIR "$HOME/workspace"

ENTRYPOINT ["/entrypoint.sh", "opencode"]
