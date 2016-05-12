#
# Cookbook Name:: chef_collector
# Recipe:: swapspace
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

bash 'make_swap' do
  cwd '/'
  code <<-EOH
    /bin/dd if=/dev/zero of=#{node['chef_collector']['swap']['path']} bs=1M count=#{node['chef_collector']['swap']['size']}
    /sbin/mkswap #{node['chef_collector']['swap']['path']}
    echo "#{node['chef_collector']['swap']['path']} node swap sw 0 0" >> /etc/fstab
    /sbin/swapon -a
  EOH
  not_if { ::File.exists?(node['chef_collector']['swap']['path']) }
end
