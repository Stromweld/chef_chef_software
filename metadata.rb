name 'chef_software'
maintainer 'Corey Hemminger'
maintainer_email 'hemminger@hotmail.com'
license 'Apache-2.0'
description 'Installs/Configures chef server, chef automate2, chef supermarket'
version '2.2.1'
chef_version '>= 16.4'

issues_url 'https://github.com/Stromweld/chef_software/issues'
source_url 'https://github.com/Stromweld/chef_software'

%w(centos redhat ubuntu).each do |os|
  supports os
end

depends 'chef-ingredient'
