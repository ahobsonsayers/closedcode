#!/bin/bash
set -e

if [ -n "$APT_PACKAGES" ]; then
	sudo apt-get update
	sudo apt-get install -y $APT_PACKAGES
	sudo rm -rf /var/lib/apt/lists/*
fi

if [ -n "$BREW_PACKAGES" ]; then
	brew install $BREW_PACKAGES
fi

exec "$@"
