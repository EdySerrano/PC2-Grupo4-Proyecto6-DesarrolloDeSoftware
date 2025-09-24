#!/usr/bin/env bash
set -euo pipefail

DOMAIN="${1:-google.com}"
dig +short "$DOMAIN" A
