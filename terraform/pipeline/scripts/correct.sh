#!/usr/bin/env bash

printf "Running Command:\n"
printf "\e[1mchef-run \`terraform output np_prod_unmanaged_public_ips\` effortless_dca::correct --user centos\e[0m\n"

if [ -z "$1" ]
then
chef-run `terraform output np_prod_unmanaged_public_ips` effortless_dca::correct --user centos
else
chef-run `terraform output np_prod_unmanaged_public_ips` effortless_dca::correct --user centos -i $1
fi