# frozen_string_literal: true

describe file('/usr/local/bin/chef-automate') do
  it { should_not exist }
end

bin_path = if os.debian?
             '/bin/chef-automate'
           else
             '/usr/bin/chef-automate'
           end

describe file(bin_path) do
  it { should exist }
end

describe command('chef-automate version') do
  its('exit_status') { should eq 0 }
end

describe service('chef-automate') do
  it { should be_installed }
  it { should be_running }
  it { should be_enabled }
end

%w(80 443).each do |port|
  describe port(port) do
    it { should be_listening }
  end
end

# TODO: uncomment when resource are out of experimental
# describe habitat_packages do
#   its('names') { should include 'automate-ui' }
#   its('names') { should include 'automate-cs-oc-erchef' }
#   its('names') { should include 'automate-builder-api' }
#   its('names') { should include 'automate-postgresql' }
#   its('names') { should include 'automate-opensearch' }
#   its('names') { should include 'automate-load-balancer' }
# end
#
# describe habitat_services do
#   its('names') { should include 'automate-ui' }
#   its('names') { should include 'automate-cs-oc-erchef' }
#   its('names') { should include 'automate-builder-api' }
#   its('names') { should include 'automate-postgresql' }
#   its('names') { should include 'automate-opensearch' }
#   its('names') { should include 'automate-load-balancer' }
# end
