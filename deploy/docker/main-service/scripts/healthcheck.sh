#!/usr/bin/env bash


set -euo pipefail


curl -f http://localhost:8501/_stcore/health || exit 1