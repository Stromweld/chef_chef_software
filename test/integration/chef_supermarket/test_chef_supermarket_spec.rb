describe package('supermarket') do
  it { should be_installed }
end

describe service('supermarket-runsvdir-start') do
  it { should be_installed }
  it { should be_running }
  it { should be_enabled }
end

%w(80 443).each do |port|
  describe port(port) do
    it { should be_listening }
  end
end
