#!/bin/bash
# MqxForge UI Launcher — delegates to install.sh
cd "$(dirname "$0")"
exec ./install.sh "$@"
