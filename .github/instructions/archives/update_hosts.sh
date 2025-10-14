#!/bin/bash

# List of local service domains
DOMAINS=(
  moodle.simondatalab.de
  ml-api.simondatalab.de
  jupyter.simondatalab.de
  mlflow.simondatalab.de
  bitbucket.simondatalab.de
)

HOSTS_LINE="127.0.0.1   ${DOMAINS[*]}"

# Check if the line already exists
if grep -q "${DOMAINS[0]}" /etc/hosts; then
    echo "Domains already present in /etc/hosts"
else
    echo "Adding local domains to /etc/hosts..."
    echo "$HOSTS_LINE" | sudo tee -a /etc/hosts
    echo "Done."
fi
