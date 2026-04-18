#!/usr/bin/env bash
set -euo pipefail
export LANG=C.UTF-8
export LC_ALL=C.UTF-8

export MISE_HIDE_UPDATE_WARNING=1

COLOR_PREFIX="\033[1;36m[Entrypoint]\033[0m"
log() {
  printf "${COLOR_PREFIX} %s\n" "$1"
}

DOCKER_DATA_ROOT="${DOCKER_DATA_ROOT:-/var/lib/docker}"
DOCKER_HOST="${DOCKER_HOST:-unix:///var/run/docker.sock}"
DOCKER_START_TIMEOUT="${DOCKER_START_TIMEOUT:-30}"
APP_DIR="${APP_DIR:-/app}"
APP_ENTRY="${APP_ENTRY:-server.js}"

export DOCKER_HOST
export DOCKER_TLS_CERTDIR="${DOCKER_TLS_CERTDIR:-}"

mkdir -p /var/log "${DOCKER_DATA_ROOT}"

log "starting dockerd..."
dockerd \
  --data-root="${DOCKER_DATA_ROOT}" \
  --host=unix:///var/run/docker.sock \
  > /var/log/dockerd.log 2>&1 &

dockerd_pid=$!

cleanup() {
  if kill -0 "${dockerd_pid}" 2>/dev/null; then
    log "stopping dockerd (pid=${dockerd_pid})..."
    kill "${dockerd_pid}" 2>/dev/null || true
    wait "${dockerd_pid}" 2>/dev/null || true
  fi
}

trap cleanup EXIT INT TERM

log "waiting for dockerd to be ready..."
start_ts="$(date +%s)"
while ! docker info >/dev/null 2>/tmp/docker-start-check.log; do
  if ! kill -0 "${dockerd_pid}" 2>/dev/null; then
    log "dockerd exited unexpectedly"
    tail -n 100 /var/log/dockerd.log || true
    tail -n 50 /tmp/docker-start-check.log || true
    exit 1
  fi

  now_ts="$(date +%s)"
  if [ $((now_ts - start_ts)) -ge "${DOCKER_START_TIMEOUT}" ]; then
    log "dockerd did not become ready in ${DOCKER_START_TIMEOUT}s"
    tail -n 100 /var/log/dockerd.log || true
    tail -n 50 /tmp/docker-start-check.log || true
    exit 1
  fi
  sleep 1
done

log "dockerd is ready"

bash /app/docker-entrypoint.sh