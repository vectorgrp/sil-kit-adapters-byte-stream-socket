#!/bin/bash
# SPDX-FileCopyrightText: Copyright 2025 Vector Informatik GmbH
# SPDX-License-Identifier: MIT

PORT="${1:-1234}" # Default port: 1234

echo "[info] TCP server awaiting connection on port $PORT..."
echo "[info] Press CTRL + C to stop the process..."

socat -v TCP4-LISTEN:"$PORT",reuseaddr,fork SYSTEM:"cat"
