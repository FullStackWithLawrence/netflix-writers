#!/usr/bin/env bash
###############################################################################
# Author: Lawrence McDaniel https://lawrencemcdaniel.com
# Date: 2026-06-26
#
# setup.sh — Debian/Ubuntu Environment Setup for netflix-writers Project
#
# This script verifies and installs required development tools for the
# netflix-writers project on Debian and Ubuntu using Homebrew (Linuxbrew).
#
# Usage:
#   bash setup.sh
#
# Requirements:
#   - Debian 12+ or Ubuntu 22.04+
#   - sudo privileges
#   - Internet connectivity
#
# Actions performed:
#   - Installs prerequisite system packages
#   - Verifies Homebrew is installed
#   - Installs development dependencies via Homebrew
#
# Exit codes:
#   0 — Success
#   1 — Missing prerequisite or failed installation
#
###############################################################################

set -euo pipefail

echo "[INFO] Verifying operating system..."

if [[ ! -f /etc/os-release ]]; then
    echo "[ERROR] Unable to determine operating system."
    exit 1
fi

source /etc/os-release

if [[ "${ID}" != "ubuntu" && "${ID}" != "debian" ]]; then
    echo "[ERROR] Unsupported operating system: ${PRETTY_NAME}"
    echo "This script supports Debian and Ubuntu only."
    exit 1
fi

echo "[OK] Detected ${PRETTY_NAME}"

echo ""
echo "[INFO] Installing Linux prerequisites..."

sudo apt-get update

sudo apt-get install -y \
    build-essential \
    procps \
    curl \
    file \
    git

echo "[OK] Linux prerequisites installed."

echo ""
echo "[INFO] Verifying Homebrew..."

if ! command -v brew >/dev/null 2>&1; then
    echo "[ERROR] Homebrew is not installed."
    echo ""
    echo "Install Homebrew by running:"
    echo ""
    echo '    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
    echo ""
    echo "Then add Homebrew to your shell environment:"
    echo ""
    echo '    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"'
    echo ""
    echo "Afterward, re-run this script."
    exit 1
fi

echo "[OK] Homebrew is installed."

#
# Ensure brew is available in the current shell
#
eval "$(brew shellenv)"

echo ""
echo "[INFO] Updating Homebrew..."

brew update

echo ""
echo "[INFO] Installing development dependencies..."

brew install python@3.13

brew install \
    sqlite \
    readline \
    xz \
    ca-certificates \
    zstd \
    openblas \
    libffi \
    openssl@3 \
    libxml2 \
    libxslt \
    geos \
    jq

echo ""
echo "=============================================="
echo " Installed Packages Summary"
echo "=============================================="

echo ""

echo "Homebrew:"
brew --version | head -n 1

echo ""

echo "Python:"
python3 --version

echo ""

echo "Other Homebrew packages:"
brew list --versions \
    sqlite \
    readline \
    xz \
    ca-certificates \
    zstd \
    openblas \
    libffi \
    openssl@3 \
    libxml2 \
    libxslt \
    geos \
    jq

echo ""
echo "=============================================="
echo "Setup complete."
echo ""
echo "Next steps:"
echo ""
echo "    python3 -m venv .venv"
echo "    source .venv/bin/activate"
echo "    python -m pip install --upgrade pip"
echo "    pip install -r requirements.txt"
echo ""
