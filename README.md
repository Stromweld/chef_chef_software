# chef_software

This Cookbook wraps the chef-ingredient cookbook and will install and configure chef-server, chef-automatev2, and an internal chef-supermarket. Configuration is all attribute driven.

## Requirements

Please refer to the chef-ingredient cookbook <https://github.com/chef-cookbooks/chef-ingredient> for additional information on configuration options to add to the atribute hashes.

### Platforms

- Linux

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
1. Build chef-automatev2 server first. Create an admin token and update `automate_admin_token` attribute.
1. Build chef-server second. Update `chef_supermarket` attribute with the correct settings found on the chef server at `/etc/opscode/oc-id-applications/supermarket.json`
1. Build chef-supermarket third.
