current_dir = File.dirname(__FILE__)
cookbook_path [
  "#{current_dir}/cookbooks",
  "/var/chef/cookbooks",
  "/var/chef/site-cookbooks",
  "/etc/chef/cookbooks",
  "/tmp/centos_test/cookbooks"
]
verbose_logging true
