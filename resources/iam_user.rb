# To learn more about Custom Resources, see https://docs.chef.io/custom_resources.html
#
# Author:: Corey Hemminger
# Cookbook:: chef_software
# Resource:: iam_user
#
# Copyright:: 2024, Corey Hemminger
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
unified_mode true
provides :iam_user

description 'manage IAM users'

property :name, String,
         name_property: true,
         description: 'Name of the IAM user'

property :user_hash, Hash,
         required: true,
         sensitive: true,
         description: 'User json in ruby hash format'

property :api_token, String,
         required: true,
         # sensitive: true,
         description: 'Automate API token'

action :create do
  description 'Create a new IAM user'

  name = new_resource.name
  user_hash = new_resource.user_hash
  user_json = user_hash.to_json
  api_token = new_resource.api_token
  # Try to fetch user from server
  srv_user = get_iam_user(user_hash['id'], api_token)
  # Test if user on server exists and any errors contacting server
  test_result = if srv_user['error'].eql?('No user record found')
                  true
                elsif srv_user['error']
                  raise srv_user['error'].inspect
                elsif srv_user['user']['id'].eql?(user_hash['id'])
                  false
                else
                  raise "Unable to determine status of user, ensure this user_hash id doesn't match an existing srv_user\nuser_hash: #{user_hash['id'].inspect}\nsrv_user: #{srv_user['id'].inspect}\nor the error message from server says 'No user record found'\nError_msg: #{srv_user['error'].inspect}\n"
                end
  ruby_block "create local user #{name}" do
    block do
      cmd = shell_out("curl --insecure -s -H \"api-token: #{api_token}\" -H \"Content-Type: application/json\" -d '#{user_json}' https://localhost/apis/iam/v2/users")
      raise cmd.stderr unless cmd.stderr.empty?
      output = Mash.new(JSON.parse(cmd.stdout))
      raise output['error'] if output['error']
    end
    only_if { test_result }
    sensitive true
  end
end

action :update do
  name = new_resource.name
  user_hash = new_resource.user_hash
  user_json = user_hash.to_json
  api_token = new_resource.api_token
  # Try to fetch user from server
  srv_user = get_iam_user(user_hash['id'], api_token)
  # Test user from server and desired user match key by key from desired policy
  test_result = if srv_user['error']
                  raise srv_user['error'].inspect
                else
                  user_hash['id'].eql?(srv_user['user']['id']) && user_hash['name'].eql?(srv_user['user']['name'])
                end
  ruby_block "update local user #{name}" do
    block do
      cmd = shell_out("curl -X PUT --insecure -s -H \"api-token: #{api_token}\" -H \"Content-Type: application/json\" -d '#{user_json}' https://localhost/apis/iam/v2/users/#{user_hash['id']}")
      raise cmd.stderr unless cmd.stderr.empty?
      output = Mash.new(JSON.parse(cmd.stdout))
      raise output['error'] if output['error']
    end
    not_if { test_result }
    sensitive true
  end
end
