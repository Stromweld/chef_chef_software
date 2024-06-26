# To learn more about Custom Resources, see https://docs.chef.io/custom_resources.html
#
# Author:: Corey Hemminger
# Cookbook:: chef_software
# Resource:: iam_policy
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
provides :iam_policy

description 'manage IAM policies'

property :name, String,
         name_property: true,
         description: 'Name of the IAM policy'

property :policy_hash, Hash,
         required: true,
         description: 'Policy json in ruby hash format'

property :api_token, String,
         required: true,
         sensitive: true,
         description: 'Automate API token'

action :create do
  description 'Create a new IAM user'

  name = new_resource.name
  policy_hash = new_resource.policy_hash
  policy_json = policy_hash.to_json
  api_token = new_resource.api_token
  # Try to fetch policy from server
  srv_policy = get_iam_policy(policy_hash['id'], api_token)
  # Test if policy on server exists and any errors contacting server
  test_result = if srv_policy['error'].eql?("no policy with ID \"#{policy_hash['id']}\" found")
                  true
                elsif srv_policy['error']
                  raise srv_policy['error'].inspect
                elsif srv_policy['policy']['id'].eql?(policy_hash['id'])
                  false
                else
                  raise "Unable to determine status of policy ensure this policy_hash id doesn't match an existing srv_policy\npolicy_hash: #{policy_hash['id'].inspect}\nsrv_policy: #{srv_policy['id'].inspect}\nor the error message from server says \"no policy with ID \"#{policy_hash['id']}\" found\"\nError_msg: #{srv_policy['error'].inspect}\n"
                end
  ruby_block "create iam policy #{name}" do
    block do
      cmd = shell_out("curl --insecure -s -H \"api-token: #{api_token}\" -H \"Content-Type: application/json\" -d '#{policy_json}' https://localhost/apis/iam/v2/policies")
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
  policy_hash = new_resource.policy_hash
  policy_json = policy_hash.to_json
  api_token = new_resource.api_token
  # Try to fetch policy from server
  srv_policy = get_iam_policy(policy_hash['id'], api_token)
  Chef::Log.info("\nuserpolicy: #{policy_json.inspect}\nsrv_policy: #{srv_policy.inspect}\n")
  # Test policy from server and desired policy match key by key from desired policy
  test_result = if srv_policy['error']
                  raise srv_policy['error'].inspect
                else
                  test = true
                  policy_hash.each_key do |key|
                    if key.eql?('statements')
                      policy_hash['statements'].each_index do |i|
                        policy_hash['statements'][i].each_key do |statement_key|
                          test = policy_hash['statements'][i][statement_key].eql?(srv_policy['policy']['statements'][i][statement_key])
                          break if test.eql?(false)
                        end
                        break if test.eql?(false)
                      end
                      break if test.eql?(false)
                      next
                    end
                    break if test.eql?(false)
                    test = policy_hash[key].eql?(srv_policy['policy'][key])
                    break if test.eql?(false)
                  end
                  test
                end
  ruby_block "update iam policy #{name}" do
    block do
      cmd = shell_out("curl -X PUT --insecure -s -H \"api-token: #{api_token}\" -H \"Content-Type: application/json\" -d '#{policy_json}' https://localhost/apis/iam/v2/policies/#{policy_hash['id']}")
      raise cmd.stderr unless cmd.stderr.empty?
      output = Mash.new(JSON.parse(cmd.stdout))
      raise output['error'] if output['error']
    end
    not_if { test_result }
    sensitive true
  end
end
