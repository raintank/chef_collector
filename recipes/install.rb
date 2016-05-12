#
# Cookbook Name:: chef_collector
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

packagecloud_repo node[:chef_collector][:packagecloud_repo] do
  type "deb"
end

pkg_version = node['chef_collector']['version']
pkg_action = if pkg_version.nil?
  :upgrade
else
  :install
end

package "node-raintank-collector" do
  version pkg_version
  action pkg_action
  notifies :restart, 'service[raintank-collector]', :delayed
end

directory "/etc/raintank/collector" do
  owner "root"
  group "root"
  mode "0755"
  recursive true
  action :create
end

template '/etc/init/raintank-collector.conf' do
  source 'raintank-collector.conf.erb'
  mode '0644'
  owner 'root'
  group 'root'
  action :create
  variables({
    collector_config: node['chef_collector']['collector_config'],
    nice_level: node['chef_collector']['nice_level']
  })
end

service "raintank-collector" do
  case node["platform"]
  when "ubuntu"
    if node["platform_version"].to_f >= 9.10
      provider Chef::Provider::Service::Upstart
    end
  end
  action [ :enable, :start]
end

collector_name =  node['chef_collector']['collector_name'] || node.hostname
template node['chef_collector']['collector_config'] do
  source 'config.json.erb'
  mode '0644'
  owner 'root'
  group 'root'
  action :create
  variables({
    collector_name: collector_name,
    num_cpus: node['chef_collector']['num_cpus'] || node.cpu.total,
    server_url: node['chef_collector']['server_url'],
    api_key: node['chef_collector']['api_key'],
    ping_port: node['chef_collector']['ping_port']
  })
  # notifies ....
  notifies :restart, 'service[raintank-collector]', :delayed
end

include_recipe "logrotate"
logrotate_app "raintank-collector" do
  path "/var/log/upstart/raintank-collector.log"
  frequency "hourly"
  create "644 root root"
  rotate 12
  enable true
end
cron "raintank-collector-rotate" do
  time :hourly
  command "/usr/sbin/logrotate /etc/logrotate.d/raintank-collector"
end

tag("collector")
