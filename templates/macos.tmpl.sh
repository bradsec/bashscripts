#!/usr/bin/env bash

# macos.sh
# Functions/commands specific to macOS systems.
# Requires: generic.sh template to be loaded first.

TEMPLATE_NAME="MACOS"

# Check if Xcode command line tools are installed.
check_xcode() {
    message INFO "Checking for Xcode command line tools..."
    if xcode-select -p >/dev/null 2>&1; then
        message DONE "Xcode command line tools are already installed."
    else
        message WARN "Xcode command line tools are not installed."
        message INFO "Attempting to install Xcode command line tools..."
        if xcode-select --install >/dev/null 2>&1; then
            message INFO "Xcode command line tools are now installing..."
        else
            message FAIL "Xcode command line tools installation failed."
            exit 1
        fi
    fi
}

message INFO "${TEMPLATE_NAME} TEMPLATE IMPORTED."