#!/bin/bash

if [ $# -ne 4 ]; then
  echo "Usage: ./deployment_status.sh APP SHORT_NAME ENV CHANNEL"
  exit 1
else
  app_ident=$1
  app_shortname=$2
  env=$3
  channel=$4
  if [[ $channel == *"blue"* || $channel == *"green"* || $channel == *"prod-"* ]]; then
    jq_query="[.census_groups.\"$${app_ident}.$${channel}\".population[].pkg][0]"
  else
    jq_query="[.census_groups.\"$${app_ident}.$${env}\".population[].pkg][0]"
  fi

  latest_version=$(curl -s https://bldr.habitat.sh/v1/depot/channels/${origin}/$${channel}/pkgs/$${app_ident}/latest\?target\=x86_64-linux | jq -r '.ident | .release')
  running_version=$(curl -s http://${tag_name}-$${app_shortname}-peer-$${env}.chef-demo.com:9631/census | jq -r "$${jq_query} | .release")

  echo "$${env} is currently running build $${running_version} from the $${channel} channel."
  echo "Latest build in $${channel} is: $${latest_version}"

  while [ "$latest_version" != "$running_version" ]
  do
    echo "Waiting for deploy to complete..."
    sleep 5
    echo ". . . . . . . . ."
    running_version=$(curl -s http://${tag_name}-$${app_shortname}-peer-$${env}.chef-demo.com:9631/census | jq -r "$${jq_query} | .release")
  done
  echo "...deploy complete!"
  exit 0
fi