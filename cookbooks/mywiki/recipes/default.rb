
directory "#{node['www']}/mywiki/#{node['mywiki']['name']}-#{node['mywiki']['version']}" do
  owner "webadmin"
  group "webadmin"
  mode "644"
  recursive true
  action :create
end


template "#{node['nginx']['dir']}/sites-enabled/default" do
  source 'mywiki.erb'
  owner  'root'
  group  'root'
  mode   '0644'
  action :create
end

template "#{node['www']}/mywiki/#{node['mywiki']['name']}-#{node['mywiki']['version']}/managewiki.py" do
	source	'managewiki.py.erb'
	owner 	'root'
	group	'root'
	mode	'0755'
  action :create
end

template "/etc/init.d/wikiserver" do
  source  'wikiserver.erb'
  owner   'root'
  group 'root'
  mode  '0755'
  action :create
end


cookbook_file "mywiki.tar.gz" do
  path "#{node['www']}/mywiki.tar.gz"
  action :create_if_missing
end

bash "extract mywiki.tar.gz" do
  cwd "#{node['www']}"
  code <<-EOH
  tar -xvf mywiki.tar.gz
  EOH
  not_if { File.exists?("#{node['www']}/mywiki/moin-1.9.7/wikiserver.py")}
  notifies :restart, 'service[wikiserver]'
end

service 'wikiserver' do
  supports :restart => true, :start => true, :stop =>true
  action   :enable
end
