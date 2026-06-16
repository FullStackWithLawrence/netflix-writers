#!/bin/bash
###############################################################################
# Author: Lawrence McDaniel https://lawrencemcdaniel.com
# Date: 2026-06-26
#
# setup.sh — macOS Environment Setup for netflix-writers Project
#
# This script verifies and installs required development tools for the netflix-writers project on macOS.
# It checks for Xcode Command Line Tools, and Homebrew and installs essential
# packages and libraries via Homebrew.
#
# Usage:
#   bash setup.sh
#
# Requirements:
#   - macOS
#   - Administrator privileges (for some installations and symlinks)
#
# Actions performed:
#   - Verifies Xcode Command Line Tools, Homebrew
#   - Installs development dependencies (python, etc.)
#
# Exit codes:
#   0 — Success
#   1 — Missing prerequisite or failed installation
#
###############################################################################

# open "macappstore://itunes.apple.com/app/id497799835"
echo "Xcode Command Line Tools:"
if ! xcode-select -p &>/dev/null; then
    echo "[INFO] Installing Xcode Command Line Tools..."
    xcode-select --install
    exit 1
fi
echo -e "\033[0;32m[OK]\033[0m Xcode Command Line Tools are installed."


# Verify prerequisites: Xcode, Homebrew, Docker Desktop
echo "[INFO] Verifying required tools..."

# Check for Xcode Command Line Tools
if ! xcode-select -p &>/dev/null; then
	echo -e "\033[0;31m[ERROR]\033[0m Xcode Command Line Tools are not installed."
	echo "Please install them by running: xcode-select --install"
	exit 1
else
	echo -e "\033[0;32m[OK]\033[0m Xcode Command Line Tools are installed."
fi

# Check for Homebrew
if ! command -v brew &>/dev/null; then
	echo -e "\033[0;31m[ERROR]\033[0m Homebrew is not installed."
	echo "Please install Homebrew from https://brew.sh/"
	exit 1
else
	echo -e "\033[0;32m[OK]\033[0m Homebrew is installed."
fi

brew update
brew install python@3.13
brew install sqlite readline xz ca-certificates zlib zstd openblas libffi openssl@3 libxml2 libxslt geos jq

echo ""
echo "=============================================="
echo " Installed Packages Summary"
echo "=============================================="

echo "Homebrew:"
brew --version | head -n 1

echo "python:"
python3 --version

echo "Other Homebrew packages:"
brew list --versions sqlite readline xz ca-certificates zlib zstd openblas libffi openssl@3 libxml2 libxslt geos jq

echo "=============================================="
