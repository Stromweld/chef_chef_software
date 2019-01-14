#
# Cookbook:: chef_software
# Attributes:: default
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

default['chef_software']['chef_server_api_fqdn'] = 'chef-server.example.com'
default['chef_software']['chef_automate_api_fqdn'] = 'chef-automate.example.com'
default['chef_software']['chef_supermarket_api_fqdn'] = 'chef-supermarket.example.com'
default['chef_software']['automate_admin_token'] = nil

default['chef_software']['chef_automatev2'] = {
  accept_license: true,
  config: <<~EOC
    [global.v1]
      fqdn = "#{node['chef_software']['chef_automate_api_fqdn']}"
  EOC
}

default['chef_software']['automatev2_local_users'] = {
  test1: {
    full_name: 'Test 1',
    password: 'Test1234!',
    sensitive: true,
  },
}

default['chef_software']['automatev2_iam_policies'] = {
  test1: {
    policy_json: {
      subjects: ['user:local:test1'],
      action: '*',
      resource: '*',
    },
    sensitive: true,
  },
}

default['chef_software']['chef_server'] = {
  accept_license: true,
  addons: {
    'manage' => {
      accept_license: true,
    },
  },
  config: <<~EOC
    api_fqdn "#{node['chef_software']['chef_server_api_fqdn']}"
    topology "standalone"
    #{"data_collector['root_url'] = 'https://#{node['chef_software']['chef_automate_api_fqdn']}/data-collector/v0/'
data_collector['proxy'] = true
profiles['root_url'] = 'https://#{node['chef_software']['chef_supermarket_api_fqdn']}'" if node['chef_software']['chef_automate_api_fqdn']}
    #{"oc_id['applications'] ||= {}
oc_id['applications']['supermarket'] = {
  'redirect_uri' => 'https://#{node['chef_software']['chef_supermarket_api_fqdn']}/auth/chef_oauth2/callback'
}" if node['chef_software']['chef_supermarket_api_fqdn']}
  EOC
}

default['chef_software']['chef_user'] = {
  test1: {
    first_name: 'Test',
    last_name: '1',
    email: 'test1@example.com',
    password: 'Test1234!',
  },
}

default['chef_software']['chef_org'] = {
  testing: {
    org_full_name: 'Testing Chef Server',
    admins: %w(test1),
    users: %w(),
  },
}

default['chef_software']['chef_supermarket'] = {
  chef_server_url: "https://#{node['chef_software']['chef_server_api_fqdn']}",
  chef_oauth2_app_id: 'GUID',
  chef_oauth2_secret: 'GUID',
  chef_oauth2_verify_ssl: false,
  accept_license: true,
  config: {
    fqdn: node['chef_software']['chef_supermarket_api_fqdn'],
    smtp_address: 'localhost',
    smtp_port: 25,
    from_email: 'chef-supermarket@example.com',
    features: 'tools,gravatar,github,announcement,fieri',
    fieri_key: 'randomstuff',
    fieri_supermarket_endpoint: node['chef_software']['chef_supermarket_api_fqdn'],
  },
}
