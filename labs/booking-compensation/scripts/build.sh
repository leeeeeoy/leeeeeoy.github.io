#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
case "$(docker info --format '{{.Architecture}}')" in
  aarch64|arm64) build_arch=arm64 ;;
  x86_64|amd64) build_arch=amd64 ;;
  *) echo 'Unsupported Docker architecture' >&2; exit 1 ;;
esac
for project in booking-api schedule-api; do
  (cd "$project"; mkdir -p bin; CGO_ENABLED=0 GOOS=linux GOARCH="$build_arch" go build -trimpath -buildvcs=false -o bin/server ./cmd/server)
done
docker compose build booking-api schedule-api
