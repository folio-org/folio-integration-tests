#!/bin/bash

_project="${1:-project}"
_environment="${2:-environment}"

echo "====running tests for $_project in $_environment===="
mvn test -pl $_project -Dkarate.env=$_environment