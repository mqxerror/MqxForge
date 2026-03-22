#!/bin/bash
# MqxForge CLI Launcher — delegates to install.sh
cd "$(dirname "$0")"
exec ./install.sh "$@"
