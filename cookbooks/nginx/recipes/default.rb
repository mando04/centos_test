
package "wget" do
    action :install
end
package "wget" do
  action :install
end
package "openssl-devel" do
  action :install
end


user "webadmin" do
  home "/home/webadmin"
  username "webadmin"
  action :create
end


remote_file "/tmp/nginx-1.4.3.tar.gz" do
    source "http://nginx.org/download/nginx-1.4.3.tar.gz"
    not_if { File.exists?("/tmp/nginx-1.4.3.tar.gz") }
end

remote_file "/tmp/openssl-1.0.1e.tar.gz" do
    source "http://www.openssl.org/source/openssl-1.0.1e.tar.gz"
    not_if { File.exists?("/tmp/openssl-1.0.1e.tar.gz") }
end

remote_file "/tmp/pcre-8.33.tar.gz" do
    source "http://downloads.sourceforge.net/project/pcre/pcre/8.33/pcre-8.33.tar.gz?r=http%3A%2F%2Fsourceforge.net%2Fprojects%2Fpcre%2Ffiles%2Fpcre%2F8.33%2F&ts=1386125760&use_mirror=softlayer-ams"
    not_if { File.exists?("/tmp/pcre-8.33.tar.gz") }
end

directory "/apps/web/sfw/nginx/nginx-1.4.3" do
  owner "root"
  group "root"
  mode 00655
  recursive true
  action :create
end


directory "/apps/web/sfw/nginx/nginx-1.4.3/sites-available" do
  owner "root"
  group "root"
  mode 00644
  recursive true
  action :create
end

directory "/apps/web/sfw/nginx/nginx-1.4.3/sites-enabled" do
  owner "root"
  group "root"
  mode 00644
  recursive true
  action :create
end

bash "Installing Nginx from source" do
	interpreter "bash"
	user "root"
	cwd "/tmp"
	code <<-EOH
	ls -lrt .
	tar -xvf /tmp/nginx-1.4.3.tar.gz
	tar -xvf /tmp/openssl-1.0.1e.tar.gz
	tar -xvf /tmp/pcre-8.33.tar.gz
	cd /tmp/nginx-1.4.3
	./configure --prefix=/apps/web/sfw/nginx/nginx-1.4.3 --with-http_ssl_module --with-pcre=/tmp/pcre-8.33
	make
	make install
	EOH
	not_if { File.exists?("/apps/web/sfw/nginx/nginx-1.4.3/sbin/nginx") }
end

puts "Setting default templates"

template "#{node[:nginx][:conf_dir]}/nginx.conf" do
	path "#{node[:nginx][:conf_dir]}/nginx.conf"
	source "nginx.conf.erb"
  mode   '0644'

end

template "#{node[:nginx][:dir]}/index.html" do
	path "#{node[:nginx][:dir]}/html/index.html"
	source "index.html.erb" 
  mode   '0755'

end

template 'nginx.conf' do
  path   "#{node[:nginx][:conf_dir]}/nginx.conf"
  source 'nginx.conf.erb'
  owner  'root'
  group  'root'
  mode   '0644'
end

template "#{node['nginx']['dir']}/sites-enabled/default" do
  source 'default-site.erb'
  owner  'root'
  group  'root'
  mode   '0644'
end

execute "Starting nginx" do
  command "#{node[:nginx][:script_dir]}/nginx"
  not_if { File.exists?("/var/run/nginx.pid") }
end

execute "Restarting nginx" do
  command "#{node[:nginx][:script_dir]}/nginx -s reload"
  only_if { File.exists?("/var/run/nginx.pid") }
end

template "/etc/sysconfig/iptables" do
  path "/etc/sysconfig/iptables"
  source "iptables.erb"
  owner "root"
  group "root"
  mode 00600
  # notifies :restart, resources(:service => "iptables")
end

# turn off iptables... not recommended for production
execute "service iptables" do
  user "root"
  command "service iptables stop"
end


