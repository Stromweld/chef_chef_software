# Policyfile.rb - Describe how you want Chef Infra Client to build your system.
#
# For more information on the Policyfile feature, visit
# https://docs.chef.io/policyfile/

# A name that describes what the system you're building with Chef does.
name 'chef_software'

# Where to find external cookbooks:
default_source :supermarket

# run_list: chef-client will run these recipes in the order specified.
run_list 'chef_software::default'
named_run_list :chef_automatev2, 'chef_software::chef_automatev2'
named_run_list :chef_server, 'chef_software::chef_server'
named_run_list :chef_supermarket, 'chef_software::chef_supermarket'

# Specify a custom source for a single cookbook:
cookbook 'chef_software', path: '.'
cookbook 'chef-ingredient', git: 'https://github.com/stromweld/chef-ingredient.git', branch: 'main'
