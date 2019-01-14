#
# Cookbook:: chef_software
# Recipe:: chef_server
#
# Copyright:: 2019, Corey Hemminger
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

chef_server 'chef-server' do
  node['chef_software']['chef_server']&.each do |key, value|
    send(key, value)
  end
end

if node['chef_software']['chef_automate_api_fqdn'] && node['chef_software']['automate_admin_token']
  execute 'set data_collector token' do
    command "chef-server-ctl set-secret data_collector token '#{node['chef_software']['automate_admin_token']}'"
    not_if { shell_out('chef-server-ctl show-secret data_collector token').stdout.include?(node['chef_software']['automate_admin_token']) }
    notifies :run, 'execute[chef-server-ctl restart nginx]', :immediately
    notifies :run, 'execute[chef-server-ctl restart opscode-erchef]', :immediately
    sensitive true
  end

  execute 'chef-server-ctl restart nginx' do
    action :nothing
  end

  execute 'chef-server-ctl restart opscode-erchef' do
    action :nothing
  end
end

ingredient_config 'chef-server' do
  notifies :reconfigure, 'chef_server[chef-server]', :immediately
end

node['chef_software']['chef_user']&.each do |name, hash|
  chef_user name do
    hash&.each do |key, value|
      send(key, value)
    end
  end
end

node['chef_software']['chef_org']&.each do |name, hash|
  chef_org name do
    hash&.each do |key, value|
      send(key, value)
    end
  end
end
