#!/bin/bash

if [ $# -ne 4 ]; then
  echo "Usage: ./health_check.sh APP SHORT_NAME ENV"
  exit 1
else
  app_ident=$1
  app_shortname=$2
  env=$3
  channel=$4
fi

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

dep_count=$(curl -s https://bldr.habitat.sh/v1/depot/channels/${origin}/stable/pkgs/national-parks/latest\?target\=x86_64-linux | jq -r '.tdeps[].name' | wc -l)
curr_count=0

if [[ $channel == *"blue"* || $channel == *"green"* ]]; then
  jq_query="[.census_groups.\"$${app_ident}.$${channel}\".population[].sys][0]"
else
  jq_query="[.census_groups.\"$${app_ident}.$${env}\".population[].sys][0]"
fi

np_ip=$(curl -s http://${tag_name}-$${app_shortname}-peer-$${env}.chef-demo.com:9631/census | jq -r "$${jq_query} | .ip")

while [ $curr_count -lt $dep_count ]
do
  stable_name=$(curl -s https://bldr.habitat.sh/v1/depot/channels/${origin}/stable/pkgs/national-parks/latest\?target\=x86_64-linux | jq -r ".tdeps[$curr_count].name")
  stable_ver=$(curl -s https://bldr.habitat.sh/v1/depot/channels/${origin}/stable/pkgs/national-parks/latest\?target\=x86_64-linux | jq -r ".tdeps[$curr_count].version")
  stable_release=$(curl -s https://bldr.habitat.sh/v1/depot/channels/${origin}/stable/pkgs/national-parks/latest\?target\=x86_64-linux | jq -r ".tdeps[$curr_count].release")
  stable_pkg="$${stable_name}: $${stable_ver}/$${stable_release}"

  running_name=$(curl -s http://$${np_ip}:9631/services/$${app_ident}/$${env} | jq -r ".pkg.deps[$curr_count] | .name")
  running_ver=$(curl -s http://$${np_ip}:9631/services/$${app_ident}/$${env} | jq -r ".pkg.deps[$curr_count] | .version")
  running_release=$(curl -s http://$${np_ip}:9631/services/$${app_ident}/$${env} | jq -r ".pkg.deps[$curr_count] | .release")
  running_pkg="$${running_name}: $${running_ver}/$${running_release}"



  if [[ $stable_pkg == $running_pkg ]]; then
    echo -e "$${GREEN}Dependency $${stable_name} matches!$${NC}"
  else
    echo -e "$${RED}Dependency mismatch!"
    echo -e "$${GREEN}Stable: $${stable_name}: $${stable_ver}/$${stable_release}"
    echo -e "$${RED}Dev: $${running_name}: $${running_ver}/$${running_release}$${NC}"
  fi

  curr_count=$(( $curr_count + 1 ))

done

