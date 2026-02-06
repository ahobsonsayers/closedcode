FROM arranhs/closedagent:latest

ARG OPENCODE_VERSION=1.1.53

# Install opencode
RUN bun install --global opencode-ai@$OPENCODE_VERSION

ENV OPENCODE_CONFIG='{ \
    "$schema": "https://opencode.ai/config.json", \
    "autoupdate": false \
  }'

# Setup persistence
RUN mkdir -p "$HOME/.config/opencode" && \
    mkdir -p "$HOME/.local/share/opencode"

VOLUME "$HOME/.config/opencode"
VOLUME "$HOME/.local/share/opencode"

# Change workspace
WORKDIR "$HOME/workspace"

ENTRYPOINT ["/entrypoint.sh", "bun", "run", "opencode"]
