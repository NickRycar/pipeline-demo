execute 'Run Remediation' do
  command "hab svc load #{node['effortless_dca']['infra_origin']}/#{node['effortless_dca']['infra_package']}"
  action :run
  not_if "hab sup status #{node['effortless_dca']['infra_origin']}/#{node['effortless_dca']['infra_package']}"
end

execute 'Unload Audit' do
  command "hab svc unload #{node['effortless_dca']['audit_origin']}/#{node['effortless_dca']['audit_package']}"
  action :run
  only_if "hab sup status #{node['effortless_dca']['audit_origin']}/#{node['effortless_dca']['audit_package']}"
end

execute 'Reload Audit' do
  command "sleep 5 && hab svc load #{node['effortless_dca']['audit_origin']}/#{node['effortless_dca']['audit_package']}"
  action :run
end
