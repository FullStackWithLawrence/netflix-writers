###############################################################################
# Author: Lawrence McDaniel https://lawrencemcdaniel.com
# Date: 2026-06-26
#
# setup.ps1 — Windows Environment Setup for netflix-writers Project
#
# This script verifies and installs required development tools for the
# netflix-writers project on Windows.
#
# Usage:
#   powershell -ExecutionPolicy Bypass -File setup.ps1
#
# Requirements:
#   - Windows 10 or Windows 11
#   - Administrator privileges
#
# Actions performed:
#   - Verifies Winget is available
#   - Installs Python 3.13
#   - Installs Git (optional but recommended)
#   - Displays installed versions
#
# Exit codes:
#   0 — Success
#   1 — Missing prerequisite or failed installation
#
###############################################################################

Write-Host "[INFO] Verifying required tools..." -ForegroundColor Cyan

#
# Verify Winget
#
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "[ERROR] Winget is not installed." -ForegroundColor Red
    Write-Host "Please install the Microsoft App Installer from the Microsoft Store."
    exit 1
}

Write-Host "[OK] Winget is installed." -ForegroundColor Green

#
# Install Python 3.13
#
Write-Host ""
Write-Host "[INFO] Installing Python 3.13..." -ForegroundColor Cyan

winget install `
    --id Python.Python.3.13 `
    --exact `
    --accept-package-agreements `
    --accept-source-agreements

#
# Install Git (recommended)
#
Write-Host ""
Write-Host "[INFO] Installing Git..." -ForegroundColor Cyan

winget install `
    --id Git.Git `
    --exact `
    --accept-package-agreements `
    --accept-source-agreements

#
# Refresh PATH for this session if possible
#
$env:Path += ";$env:LOCALAPPDATA\Programs\Python\Python313\"
$env:Path += ";$env:LOCALAPPDATA\Programs\Python\Python313\Scripts\"

Write-Host ""
Write-Host "=============================================="
Write-Host " Installed Packages Summary"
Write-Host "=============================================="

Write-Host ""
Write-Host "Winget:"
winget --version

Write-Host ""
Write-Host "Python:"
try {
    python --version
}
catch {
    Write-Host "Python was installed but is not yet available in this session."
    Write-Host "Please open a new PowerShell window and run:"
    Write-Host "    python --version"
}

Write-Host ""
Write-Host "Git:"
try {
    git --version
}
catch {
    Write-Host "Git was installed but is not yet available in this session."
    Write-Host "Please open a new PowerShell window and run:"
    Write-Host "    git --version"
}

Write-Host ""
Write-Host "=============================================="
Write-Host "Setup complete."
Write-Host "Next steps:"
Write-Host ""
Write-Host "    python -m venv .venv"
Write-Host "    .\.venv\Scripts\Activate.ps1"
Write-Host "    python -m pip install --upgrade pip"
Write-Host "    pip install -r requirements.txt"
Write-Host ""
