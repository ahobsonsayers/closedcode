#!/bin/bash
set -e

if [ -n "$APT_PACKAGES" ]; then
	apt-get update
	apt-get install -y $APT_PACKAGES
	rm -rf /var/lib/apt/lists/*
fi

if [ -n "$BREW_PACKAGES" ]; then
	brew install $BREW_PACKAGES
fi

exec "$@"
