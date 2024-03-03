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
resource_name :iam_user

description 'manage IAM users'

property :name, String,
         name_property: true,
         description: 'Name of the IAM user'

property :user_hash, String,
         required: true,
         description: 'User json in ruby hash format'

property :api_token, String,
         required: true,
         sensitive: true,
         description: 'Automate API token'

action :create do
  description 'Create a new IAM user'

  name = new_resource.name
  user_hash = new_resource.user_hash
  user_json = user_hash.to_json
  test_user = get_iam_user(user_hash['id'])
  http_request "update iam policy #{name}" do
    headers({ 'api-token' => new_resource.api_token, 'Content-Type' => 'application/json' })
    message user_json
    url 'https://localhost/apis/iam/v2/users'
    action :post
    sensitive true
    only_if { test_user['error'].eql?('No user record found') }
  end
end

action :update do
  name = new_resource.name
  user_hash = new_resource.user_hash
  user_json = user_hash.to_json
  test_user = get_iam_user(user_hash['id'])
  # Test user from server and desired user match key by key from desired policy
  test_result = if user_policy['error']
                  Chef::Log.warn(user_policy['error'].inspect)
                  true
                else
                  user_hash['id'].eql?(test_user['user']['id']) && user_hash['name'].eql?(test_user['user']['name'])
                end
  http_request "update iam user #{name}" do
    headers({ 'api-token' => new_resource.api_token, 'Content-Type' => 'application/json' })
    message user_json
    url "https://localhost/apis/iam/v2/users/#{user_hash['id']}"
    action :put
    sensitive true
    not_if { test_result }
  end
end
