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
resource_name :iam_policy

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
  srv_policy = get_iam_policy(policy_json['id'], api_token)
  # Test if policy on server exists and any errors contacting server
  test_result = if srv_policy['error'].eql?("no policy with ID \"#{policy_hash['id']}\" found")
                  true
                elsif srv_policy['error']
                  Chef::Log.error(srv_policy['error'].inspect)
                  false
                elsif srv_policy['policy']['id'].eql?(policy_hash['id'])
                  false
                else
                  false
                end
  http_request "create iam policy #{name}" do
    headers({ 'api-token' => api_token, 'Content-Type' => 'application/json' })
    message policy_json
    url 'https://localhost/apis/iam/v2/policies'
    action :post
    sensitive true
    only_if { test_result }
  end
end

action :update do
  name = new_resource.name
  policy_hash = new_resource.policy_hash
  policy_json = policy_hash.to_json
  api_token = new_resource.api_token
  # Try to fetch policy from server
  srv_policy = get_iam_policy(policy_json['id'], api_token)
  Chef::Log.info("\nuserpolicy: #{policy_json.inspect}\nsrv_policy: #{srv_policy.inspect}\n")
  # Test policy from server and desired policy match key by key from desired policy
  test_result = if srv_policy['error']
                  Chef::Log.error(srv_policy['error'].inspect)
                  true
                else
                  test = true
                  statement_test = true
                  unless srv_policy['error']
                    policy_hash.each_key do |key|
                      if key.eql?('statements')
                        policy_hash['statements'].each_index do |i|
                          policy_hash['statements'][i].each_key do |statement_key|
                            test = policy_hash['statements'][i][statement_key].eql?(srv_policy['policy']['statements'][i][statement_key])
                            break if statement_test.eql?(false)
                          end
                          break if statement_test.eql?(false)
                        end
                        break if statement_test.eql?(false)

                        next
                      end
                      test = policy_hash[key].eql?(srv_policy['policy'][key])
                      break if test.eql?(false)
                    end
                  end
                  if test && statement_test
                    true
                  else
                    false
                  end
                end
  http_request "update iam policy #{name}" do
    headers({ 'api-token' => api_token, 'Content-Type' => 'application/json' })
    message policy_json
    url "https://localhost/apis/iam/v2/policies/#{policy_hash['id']}"
    action :put
    sensitive true
    not_if { test_result }
  end
end
