#!/usr/bin/env bash
set -euo pipefail

image=${1:?Usage: smoke-test.sh IMAGE}
docker run --rm --entrypoint qbittorrent-nox "$image" --version

check_webui() (
  port=$1
  args=()
  if [[ "$port" != 8080 ]]; then
    args+=(--env "WEBUI_PORT=$port")
  fi
  response=$(mktemp)
  container=
  cleanup() {
    if [[ -n "$container" ]]; then
      docker rm --force --volumes "$container" >/dev/null
    fi
    rm -f "$response"
  }
  trap cleanup EXIT

  container=$(docker run --detach "${args[@]}" --publish "127.0.0.1::$port" "$image")
  address=$(docker port "$container" "$port/tcp")
  for ((attempt = 0; attempt < 30; attempt++)); do
    # qBittorrent validates Host's port against its own listening port, while
    # Docker publishes that port at a randomly assigned host port for the test.
    if curl --fail-with-body --silent --max-time 2 \
      --header "Host: localhost:$port" "http://$address/" > "$response" \
      && grep -q 'qBittorrent' "$response"; then
      echo "WebUI responds on container port $port"
      exit 0
    fi
    if [[ "$(docker inspect --format '{{.State.Running}}' "$container")" != true ]]; then
      break
    fi
    sleep 1
  done

  echo "WebUI failed to start on container port $port" >&2
  cat "$response" >&2
  docker logs "$container" >&2
  exit 1
)

# Exercise the default command, both with and without a WEBUI_PORT override.
check_webui 8080
check_webui 18080
