#!/bin/bash

_environment="${2:-environment}"
_project="${1:-project}"

echo "====running tests for $_project in $_environment===="
mvn test -pl $_project -Dkarate.env=$_environment