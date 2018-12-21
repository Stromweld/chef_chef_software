# # encoding: utf-8

# Inspec test for recipe chef_software::default

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

# Listening port
%w(80 443).each do |port|
  describe port(port) do
    it { should be_listening }
  end
end
