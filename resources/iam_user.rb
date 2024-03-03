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

property :user_hash, Hash,
         required: true,
         sensitive: true,
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
  api_token = new_resource.api_token
  # Try to fetch user from server
  srv_user = get_iam_user(user_hash['id'], api_token)
  # Test if user on server exists and any errors contacting server
  test_result = if srv_user['error'].eql?('No user record found')
                  true
                elsif srv_user['error']
                  Chef::Log.error(srv_user['error'].inspect)
                  false
                elsif srv_user['user']['id'].eql?(user_hash['id'])
                  false
                else
                  false
                end
  http_request "create iam user #{name}" do
    headers({ 'api-token' => api_token, 'Content-Type' => 'application/json' })
    message user_json
    url 'https://localhost/apis/iam/v2/users'
    action :post
    sensitive true
    only_if { test_result }
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
                  Chef::Log.error(srv_user['error'].inspect)
                  true
                else
                  user_hash['id'].eql?(srv_user['user']['id']) && user_hash['name'].eql?(srv_user['user']['name'])
                end
  http_request "update iam user #{name}" do
    headers({ 'api-token' => api_token, 'Content-Type' => 'application/json' })
    message user_json
    url "https://localhost/apis/iam/v2/users/#{user_hash['id']}"
    action :put
    sensitive true
    not_if { test_result }
  end
end
