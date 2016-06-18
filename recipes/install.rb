#
# Cookbook Name:: chef_probe
# Recipe:: install
#
# Copyright (C) 2016 Raintank, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

packagecloud_repo node[:chef_probe][:packagecloud_repo] do
  type "deb"
end

pkg_version = node['chef_probe']['version']
pkg_action = if pkg_version.nil?
  :upgrade
else
  :install
end

# Remove the old package if present
package "node-raintank-collector" do
  action :remove
end

service "raintank-probe" do
  action :nothing
end

package "raintank-probe" do
  version pkg_version
  action pkg_action
  notifies :restart, 'service[raintank-probe]', :delayed
end

directory "/etc/raintank" do
  owner "root"
  group "root"
  mode "0755"
  action :create
end

probe_name =  node['chef_probe']['probe_name'] || node.hostname
template node['chef_probe']['probe_config'] do
  source 'probe.ini.erb'
  mode '0644'
  owner 'root'
  group 'root'
  action :create
  variables({
    probe_name: probe_name,
    server_url: node['chef_probe']['server_url'],
    tsdb_url: node['chef_probe']['tsdb_url'], 
    api_key: node['chef_probe']['api_key'],
    log_level: node['chef_probe']['log_level']
  })
  # notifies ....
  notifies :restart, 'service[raintank-probe]', :delayed
end

service "raintank-probe" do
  case node["platform"]
  when "ubuntu"
    if node["platform_version"].to_f >= 9.10
      provider Chef::Provider::Service::Upstart
    end
  end
  action [ :enable, :start]
end

include_recipe "logrotate"
logrotate_app "raintank-probe" do
  path "/var/log/upstart/raintank-probe.log"
  frequency "hourly"
  create "644 root root"
  rotate 12
  enable true
end
cron "raintank-probe-rotate" do
  time :hourly
  command "/usr/sbin/logrotate /etc/logrotate.d/raintank-probe"
end

tag("collector")
tag("probe")
