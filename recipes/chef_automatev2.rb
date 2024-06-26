#
# Cookbook:: chef_software
# Recipe:: chef_automatev2
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

chef_automatev2 'Create Automate server' do
  node['chef_software']['chef_automatev2']&.each do |key, value|
    send(key, value)
  end
end

if kitchen?
  ruby_block 'create_automate_admin_token' do
    block do
      node.run_state['automate_admin_token'] = kitchen_create_api_token('admin')
    end
  end
end

node['chef_software']['automatev2_local_users']&.each do |name, hash|
  iam_user name do
    user_hash hash['user_json']
    api_token lazy { kitchen? ? node.run_state['automate_admin_token'] : node['chef_software']['automate_admin_token'] }
    action hash['action'] if hash['action']
  end
end

node['chef_software']['automatev2_iam_policies']&.each do |name, hash|
  iam_policy name do
    policy_hash hash['policy_json']
    api_token lazy { kitchen? ? node.run_state['automate_admin_token'] : node['chef_software']['automate_admin_token'] }
    action hash['action'] if hash['action']
  end
end

if node['chef_software']['chef_automatev2']['products']&.include?('infra-server')
  node['chef_software']['chef_user']&.each do |name, hash|
    chef_user name do
      hash&.each do |key, value|
        send(key, value)
      end
    end
  end

  node['chef_software']['chef_org']&.each do |name, hash|
    template "#{Chef::Config[:file_cache_path]}/#{name}" do
      source 'orgs.erb'
      variables org_opts: hash
      notifies :create, "chef_org[#{name}]", :immediately
    end

    chef_org name do
      hash&.each do |key, value|
        send(key, value)
      end
      action :nothing
    end
  end
end
