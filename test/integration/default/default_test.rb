# InSpec test for recipe chef_automate

# The InSpec reference, with examples and extensive documentation, can be
# found at https://www.inspec.io/docs/reference/resources/

# Listening port
%w(80 443).each do |port_num|
  describe port(port_num) do
    it { should be_listening }
  end
end
