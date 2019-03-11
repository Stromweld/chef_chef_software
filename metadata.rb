name 'chef_software'
maintainer 'Corey Hemminger'
maintainer_email 'hemminger@hotmail.com'
license 'Apache-2.0'
description 'Installs/Configures chef server, chef automate2, chef supermarket'
long_description 'Installs/Configures chef server, chef automate2, chef supermarket'
version '1.0.3'
chef_version '>= 13.0'

issues_url 'https://github.com/Stromweld/chef_software/issues'
source_url 'https://github.com/Stromweld/chef_software'

%w(centos redhat ubuntu).each do |os|
  supports os
end

depends 'chef-ingredient'
