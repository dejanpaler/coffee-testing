#!/bin/bash
set -euo pipefail

cd ${0%/*}/coffee-shop

trap cleanup EXIT

function cleanup() {
  docker stop coffee-shop coffee-shop-db barista &> /dev/null || true
}


cleanup

docker run -d --rm \
  --name coffee-shop-db \
  --network dkrnet \
  -p 5432:5432 \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres \
  postgres:9.5

docker run -d --rm \
  --name barista \
  --network dkrnet \
  -p 8002:8080 \
  rodolpheche/wiremock:2.6.0


# coffee-shop

docker build -f Dockerfile.dev -t tmp-builder .

docker run -d --rm \
  --name coffee-shop \
  --network dkrnet \
  -p 8001:8080 \
  -v /home/sebastian/.m2/:/root/.m2/ \
  tmp-builder

sleep 5

mvn compile quarkus:remote-dev -Dquarkus.live-reload.url=http://localhost:8001 -Dquarkus.live-reload.password=123
