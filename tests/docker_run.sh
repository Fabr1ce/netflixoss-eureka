#!/bin/bash

echo "rebuilding image"
docker build . -t eureka

echo "re-running the container"
docker run eureka -p 8080:8080 --rm
