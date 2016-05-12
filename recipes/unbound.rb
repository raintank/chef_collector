#
# Cookbook Name:: chef_collector
# Recipe:: unbound
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

package "unbound" do
  action :install
end

service "unbound" do
  action [ :enable, :start ]
  supports [ :restart => true ]
end

service "resolvconf" do
  action :nothing
  supports [ :restart => true ]
end

cookbook_file "/etc/unbound/unbound.conf.d/collector-dns-cache.conf" do
  source "raintank_collector_cache.conf"
  mode "0644"
  owner "root"
  group "root"
  action :create
  notifies :restart, "service[unbound]", :delayed
end

if node.attribute?('gce')
  template "/etc/unbound/unbound.conf.d/forward-zone.conf" do
    source "forward-zone.conf.erb"
    owner "root"
    group "root"
    mode "0644"
    variables({
      :forward_zone_name => "internal"
    })
    action :create
    notifies :restart, "service[unbound]", :delayed
  end
end

cookbook_file "/etc/resolvconf/resolv.conf.d/head" do
  source "collector_resolvconf.head"
  mode "0644"
  owner "root"
  group "root"
  action :create
  notifies :restart, "service[resolvconf]", :delayed
end

cookbook_file "/etc/default/unbound" do
  source "unbound.default"
  mode "0644"
  owner "root"
  group "root"
  action :create
  notifies :restart, "service[unbound]", :delayed
end
