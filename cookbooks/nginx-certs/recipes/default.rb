
package "openssl-devel" do
  action :install
end


directory "#{node['nginx']['ssl_dir']}" do
  owner "root"
  group "root"
  mode 00655
  recursive true
  action :create
end

bash "Installing Nginx from source" do
    interpreter "bash"
    user "root"
    cwd "/tmp"
    code <<-EOH
    openssl genrsa -out #{node['nginx']['ssl_dir']}/server.key 2048
    openssl req -passout pass:abcdefg -subj "/C=#{node['nginx-certs']['C']}/ST=T#{node['nginx-certs']['ST']}/L=#{node['nginx-certs']['L']}/O=#{node['nginx-certs']['O']}/OU=#{node['nginx-certs']['OU']}/CN=#{node['nginx-certs']['CN']}/emailAddress=#{node['nginx-certs']['email']}" -new -key #{node['nginx']['ssl_dir']}/server.key -out #{node['nginx']['ssl_dir']}/server.csr
    openssl x509 -req -days 365 -in #{node['nginx']['ssl_dir']}/server.csr -signkey #{node['nginx']['ssl_dir']}/server.key -out #{node['nginx']['ssl_dir']}/server.crt
    EOH
end
