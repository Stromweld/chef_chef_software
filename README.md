# chef_software

This Cookbook wraps the chef-ingredient cookbook and will install and configure chef-server, chef-automatev2, and an internal chef-supermarket. Configuration is all attribute driven.

## Requirements

Please refer to the chef-ingredient cookbook <https://github.com/chef-cookbooks/chef-ingredient> for additional information on configuration options to add to the atribute hashes.

### Platforms

- Linux

## Attributes

### default attributes

| Attribute | Default | Comment |
| -------------  | -------------  | -------------  |
| ['chef_software']['chef_server_api_fqdn'] | 'chef-server.example.com' | (String) Hostname to connect to chef-server |
| ['chef_software']['chef_automate_api_fqdn'] | 'chef-automate.example.com' | (String) Hostname to connect to chef-automatev2 |
| ['chef_software']['chef_supermarket_api_fqdn'] | 'chef-supermarket.example.com' | (String) Hostname to connect to chef-supermarket |
| ['chef_software']['automate_admin_token'] | nil | (String) Token used for api access by cookbook |
| ['chef_software']['chef_automatev2'] | {accept_license: true, config: <<~EOC [global.v1] fqdn = "#{node['chef_software']['chef_automate_api_fqdn']}" EOC} | (Hash) Used to add configuration options to chef-automatev2 |
| ['chef_software']['chef_automatev2']['local_users'] | {test1:{ full_name: 'Test 1', password: 'Test1234!',},} | (Hash) Hash of hashes definign automatev2 users |
| ['chef_software']['chef_automatev2']['iam_policies'] | {team_ldap: {policy_json: {subjects: ['user:local:test1'], action: '*', resource: '*',},},} | (Hash) Hash of hashes defining automate IAM policies in json format |
| ['chef_software']['chef_server'] | {accept_license: true, addons: {'manage' => {accept_license: true,},}, config: <<~EOC api_fqdn "#{node['chef_software']['chef_server_api_fqdn']}" topology "standalone" #{"data_collector['root_url'] = 'https://#{node['chef_software']['chef_automate_api_fqdn']}/data-collector/v0/' data_collector['proxy'] = true profiles['root_url'] = 'https://#{node['chef_software']['chef_supermarket_api_fqdn']}'" if node['chef_software']['chef_automate_api_fqdn']} #{"oc_id['applications'] ||= {} oc_id['applications']['supermarket'] = {'redirect_uri' => 'https://#{node['chef_software']['chef_supermarket_api_fqdn']}/auth/chef_oauth2/callback',}" if node['chef_software']['chef_supermarket_api_fqdn']} EOC} | (Hash) Used to add configuration options to chef-server |
| ['chef_software']['chef_user'] | {test1: {first_name: 'Test',last_name: '1',email: 'test1@example.com',password: 'Test1234!',},} | (Hash) Hash of hashes used to manage chef-server users |
| ['chef_software']['chef_org'] | {testing: {org_full_name: 'Testing Chef Server', admins: %w(test1), users: %w(),},} | (Hash) Hash of hashes used to manage chef-server organizations |
| ['chef_software']['chef_supermarket'] | {chef_server_url: "https://#{node['chef_software']['chef_server_api_fqdn']}", chef_oauth2_app_id: 'testGUID', chef_oauth2_secret: 'testGUID', chef_oauth2_verify_ssl: false, accept_license: true, config: {fqdn: node['chef_software']['chef_supermarket_api_fqdn'], smtp_address: 'localhost', smtp_port: 25, from_email: 'chef-supermarket.example.com', features: 'tools,gravatar,github,announcement,fieri', fieri_key: 'randomstuff', fieri_supermarket_endpoint: node['chef_software']['chef_supermarket_api_fqdn'],},} | (Hash) Used to add configuration options to chef-supermarket |

## Recipes

### default recipe

Recipe does nothing but log warning that it does nothing

### chef_automatev2

Recipe to install chef-automatev2

### chef_server

Recipe to install chef-server and manage users & organizations

### chef_supermarket

Recipe to install chef-supermarket

## Usage

1. Set attributes via wrapper cookbook, policy files, role or environment files. 
2. Build chef-automatev2 server first. Create an admin token and update `automate_admin_token` attribute.
3. Build chef-server second. Update `chef_supermarket` attribute with the correct settings found on the chef server at `/etc/opscode/oc-id-applications/supermarket.json`
4. Build chef-supermarket third.
