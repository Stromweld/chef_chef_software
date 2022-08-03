describe package('chef-server-core') do
  it { should be_installed }
end

describe service('private_chef-runsvdir-start') do
  it { should be_installed }
  it { should be_running }
  it { should be_enabled }
end
