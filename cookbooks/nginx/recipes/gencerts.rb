
puts "Generating certs for Nginx"

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
    openssl req -passout pass:abcdefg -subj "/C=US/ST=TX/L=Dallas/O=Test Corporation/OU=Test Software Group/CN=Rational Performance Tester CA/emailAddress=root@localhost.com" -new -key #{node['nginx']['ssl_dir']}/server.key -out #{node['nginx']['ssl_dir']}/server.csr
    openssl x509 -req -days 365 -in #{node['nginx']['ssl_dir']}/server.csr -signkey #{node['nginx']['ssl_dir']}/server.key -out #{node['nginx']['ssl_dir']}/server.crt
    EOH
    not_if { File.exists?("#{node['nginx']['ssl_dir']}/server.crt") }
end
