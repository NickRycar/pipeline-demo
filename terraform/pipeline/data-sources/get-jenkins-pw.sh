#!/bin/bash

set -eu -o pipefail

export ssh_user
export ssh_key
export jenkins_ip

eval "$(jq -r '@sh "export ssh_user=\(.ssh_user) ssh_key=\(.ssh_key) jenkins_ip=\(.jenkins_ip)"')"

jenkins_pw="$(ssh -i ${ssh_key} ${ssh_user}@${jenkins_ip} sudo cat /hab/svc/jenkins/data/secrets/initialAdminPassword)"

jq -n --arg jenkins_pw "$jenkins_pw" \
      '{"jenkins_pw":$jenkins_pw}'