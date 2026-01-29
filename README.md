# ClosedCode

OpenCode is awesome - is such a good coding agent and in my experience performs far better than Claude Code.

The problem, however, is I want to run it in a sandbox - specifically a Docker container - to reduce blast radius if the agent makes a mistake or is used maliciously. This is especially important if I "YOLO" allow all permissions - I don't want to `rm -rf /`!

This container was built to give an isolated environment to run OpenCode (including its Web UI), aptly named **ClosedCode**.

## Usage

By default, when the container is run, it will run the `opencode` command with no args in the default working dir `/home/opencode/workspace`.

To get started quickly, simply mount your folder to this working directory.

For your current working directory - this command is:

```bash
docker run -it --rm -v "$(pwd):/home/opencode/workspace" closedcode:latest
```

## Persistence and Volumes

By default, both OpenCode config and OpenCode sessions will be persisted across runs of the container - however, you might want to mount these to your host machine if you want easy access to the config files (for editing), or if you want to share config and state with OpenCode that you might run outside of this sandbox.

To mount these folders, you can run:

```bash
docker run -it --rm \
  -v "$(pwd):/home/opencode/workspace" \
  -v "<config-path>:/home/opencode/.config/opencode" \
  -v "<data-path>:/home/opencode/.local/share/opencode" \
  closedcode:latest
```

For example, if you want to use config and data used by OpenCode running on your local machine, run:

```bash
docker run -it --rm \
  -v "$(pwd):/home/opencode/workspace" \
  -v "$HOME/.config/opencode:/home/opencode/.config/opencode" \
  -v "$HOME/.local/share/opencode:/home/opencode/.local/share/opencode" \
  closedcode:latest
```

## Other files e.g. git, ssh etc.

To get the most out of OpenCode running in this sandbox, it is likely you also want to mount additional files from your local machine - such as your git config and GitHub credentials from using the gh cli (using the `gh` cli to auth with GitHub is very recommended for ease).

For these files, it is recommended to mount the files as read-only.

To do this, you can run OpenCode with:

```bash
docker run -it --rm \
  -v "$(pwd):/home/opencode/workspace" \
  -v "$HOME/.config/opencode:/home/opencode/.config/opencode" \
  -v "$HOME/.local/share/opencode:/home/opencode/.local/share/opencode" \
  -v "$HOME/.gitconfig:/home/opencode/.gitconfig:ro" \
  -v "$HOME/.ssh:/home/opencode/.ssh:ro" \
  -v "$HOME/.config/gh:/home/opencode/.config/gh:ro" \
  closedcode:latest
```

## Web UI

It is also possible to run the OpenCode Web UI for development on the go or on a UI in your local browser.

To do this, using docker compose is recommended to easily run the service in the background.

To run the Web UI using all the previously mentioned mounts, you can create a `compose.yaml` with the following content:

```yaml
services:
  closedcode:
    image: closedcode:latest
    command: ["--web", "--port", "3000"]
    ports:
      - "3000:3000" # You can use a different port
    volumes:
      - .:/home/opencode/workspace # code files
      - ~/.config/opencode:/home/opencode/.config/opencode # opencode config
      - ~/.local/share/opencode:/home/opencode/.local/share/opencode # opencode sessions
      - ~/.gitconfig:/home/opencode/.gitconfig:ro # git config
      - ~/.ssh:/home/opencode/.ssh:ro # ssh keys
      - ~/.config/gh:/home/opencode/.config/gh:ro # github cli config
```

And then run with:

```bash
docker compose up -d
```

### Extending

This image also works well as a base image to be extended and worked upon. An example of this can be seen in the openchamber repository, which offers a more feature-rich web UI for developing with OpenCode.