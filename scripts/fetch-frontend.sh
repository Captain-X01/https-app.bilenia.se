#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="${ROOT}/.env"
if [ -f "$ENV_FILE" ]; then
  set -a
  # shellcheck disable=SC1091
  source "$ENV_FILE"
  set +a
fi

FRONTEND_DIR="${ROOT}/.frontend/bilenia-dealer-panel"
REPO="${FRONTEND_GIT_URL:-}"

if [ -z "$REPO" ]; then
  echo "Sätt FRONTEND_GIT_URL i .env (kopiera från .env.example) eller exportera i shell." >&2
  echo "Exempel: FRONTEND_GIT_URL=git@github.com:ORG/bilenia-dealer-panel.git" >&2
  exit 1
fi

rm -rf "$FRONTEND_DIR"
mkdir -p "${ROOT}/.frontend"
git clone "$REPO" "$FRONTEND_DIR"

# main_proxy = live frontend; sätt FRONTEND_REF för annan branch/tag/commit
# REF="${FRONTEND_REF:-main_proxy}"
REF="${FRONTEND_REF:-feature/photo_test}"
git -C "$FRONTEND_DIR" checkout "$REF"
