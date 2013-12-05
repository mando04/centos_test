
template "#{node['nginx']['dir']}/sites-enabled/default" do
  source 'mywiki.erb'
  owner  'root'
  group  'root'
  mode   '0644'
end

template "/apps/web/www/mywiki/moin-1.9.7/restart.py" do
	source	'restart.py.erb'
	owner 	'root'
	group	'root'
	mode	'0755'
end

execute "nohup /usr/bin/python /apps/web/www/mywiki/moin-1.9.7/wikiserver.py &" do
  command "/usr/bin/python /apps/web/www/mywiki/moin-1.9.7/restart.py"
end


execute "Starting nginx" do
  command "#{node[:nginx][:script_dir]}/nginx"
  not_if { File.exists?("/var/run/nginx.pid") }
end

execute "Restarting nginx" do
  command "#{node[:nginx][:script_dir]}/nginx -s reload"
  only_if { File.exists?("/var/run/nginx.pid") }
end
