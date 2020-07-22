execute 'unload app' do
  command 'hab svc unload nrycar/national-parks'
  action :run
  only_if 'hab sup status nrycar/national-parks'
end

execute 'sleep 5'

execute 'uninstall app' do
  command 'hab pkg uninstall nrycar/national-parks'
  action :run
  only_if 'hab pkg list --all | grep nrycar/national-parks'
end

execute 're-load app' do
  command 'hab svc load nrycar/national-parks --strategy at-once --channel dev --group dev --bind database:mongodb.dev'
  action :run
  not_if 'hab sup status nrycar/national-parks'
end
