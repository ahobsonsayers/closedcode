# ClosedCode

ClosedCode is a Docker container for running OpenCode in an isolated environment.

## Why? <!-- omit from toc -->

OpenCode is a very powerful tool. However, running it directly on your host machine—especially with "YOLO" permissions—can pose security ri

**ClosedCode** runs OpenCode (including its Web UI if desired) within an isolated container environment, significantly reducing the blast radius if the agent does something dumb—particularly the dreaded `rm -rf /`.

- [Usage](#usage)
- [Environment Variables](#environment-variables)
- [Installing Additional Packages](#installing-additional-packages)
  - [Why is installation by `brew` recommended?](#why-is-installation-by-brew-recommended)
- [Persistence and Volumes](#persistence-and-volumes)
- [Other files e.g. git, ssh etc.](#other-files-eg-git-ssh-etc)
- [Web UI](#web-ui)
- [Extending](#extending)

There are a few Docker images for OpenCode out there, so what makes this one different?

- Small — at ~500MB this image is quite small by comparison to other images.
- Batteries included — comes with most of the standard tools OpenCode typically uses, and that you might need. This includes core utils, git, and ssh as expected, but also bun and gh (GitHub CLI).
  Note: To keep the image small and unopinionated, it does not have languages like Python, Node, etc., installed. See next point for info on how these are supported.
- Extensible — Extra tools, languages, or packages from either `brew` (recommended) or `apt` can be installed at runtime to add missing software that you require.

## Usage

By default, when the container is run, it will run the `opencode` command with no args in the default working directory (`/home/opencode/workspace`).

To get started quickly, simply mount your folder to this directory.

For your current working directory, this command is:

```bash
docker run -it --rm -v "$(pwd):/home/opencode/workspace" closedcode:latest
```

## Environment Variables

When running, the following environment variables can we set.

- `OPENCODE_HOSTNAME` - Address the Web UI binds to (Default: `0.0.0.0`)
- `OPENCODE_PORT` - Port the Web UI listens on (Default: `4096`)
- `OPENCODE_SERVER_USERNAME` - Username for Web UI authentication (Default: `opencode`)
- `OPENCODE_SERVER_PASSWORD` - Password for Web UI authentication (Default: not set/no auth)

## Installing Additional Packages

You can install additional packages at container startup using environment variables.

This is useful when you need languages or tools that aren't included in the base image.

You can set:

- `APT_PACKAGES` environment variable to install `apt` packages
- `BREW_PACKAGES` environment variable to install `brew` packages (recommended)

Packages should be space separated, so remember to quote your values.

For example, you can run:

```bash
docker run -it --rm \
  -v "$(pwd):/home/opencode/workspace" \
  -e "APT_PACKAGES=python3 zip" \
  -e "BREW_PACKAGES=node go" \
  closedcode:latest
```

### Why is installation by `brew` recommended?

Homebrew has a huge array of tools and packages (~7000), many of which are missing in apt. As such, Homebrew is extremely likely to have the software you require, and its cache is easy to persist, which can be leveraged to make startup installs faster. Info on this to be added.

## Persistence and Volumes

By default, both OpenCode config and OpenCode sessions will be persisted across runs of the container; however, you might want to mount these to your host machine if you want easy access to the config files (for editing), or if you want to share config and state with OpenCode that you might run outside of this sandbox.

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

To get the most out of OpenCode running in this sandbox, it is likely you also want to mount additional files from your local machine—such as your git config and GitHub credentials from using the GitHub CLI (using the `gh` CLI to auth with GitHub is highly recommended for ease).

For these files, it is recommended to mount them as read-only.

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

It is also possible to run the OpenCode Web UI for development on the go or in your local browser.

To do this, using Docker Compose is recommended to easily run the service in the background.

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

## Extending

This image also works well as a base image to be extended and worked upon. An example of this can be seen in the OpenChamber repository, which offers a more feature-rich web UI for developing with OpenCode.
