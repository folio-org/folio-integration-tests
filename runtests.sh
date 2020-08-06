#!/bin/bash
env="${2:-local}"
mvn test -pl $1 -Dkarate.env="$env"