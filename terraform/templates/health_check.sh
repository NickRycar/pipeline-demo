#!/bin/bash
if [ $# -ne 4 ]; then
  echo "Usage: ./health_check.sh APP SHORT_NAME ENV"
  exit 1
else
  app_ident=$1
  app_shortname=$2
  env=$3
  channel=$4
  
  if [[ $channel == *"blue"* || $channel == *"green"* ]]; then
    jq_query="[.census_groups.\"$${app_ident}.$${channel}\".population[].sys][0]"
  else
    jq_query="[.census_groups.\"$${app_ident}.$${env}\".population[].sys][0]"
  fi  
  
  np_ip=$(curl -s http://${tag_name}-$${app_shortname}-peer-$${env}.chef-demo.com:9631/census | jq -r "$${jq_query} | .ip")
  
  if [[ $channel == *"blue"* || $channel == *"green"* ]]; then 
  np_health=$(curl -s $${np_ip}:9631/services/$${app_ident}/$${channel}/health | jq .status)
  else
  np_health=$(curl -s $${np_ip}:9631/services/$${app_ident}/$${env}/health | jq .status)
  fi

  if [ "$np_health" = "\"OK\"" ]; then
    echo "The app is healthy!"
    exit 0
  else
    echo "Something is horribly wrong! The health check returned $${np_health}"
    echo "Running dependency check..."
    /usr/local/bin/dep_comp.sh $1 $2 $3 $4
    exit 1
  fi
fi