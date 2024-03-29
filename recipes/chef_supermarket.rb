#
# Cookbook:: chef_software
# Recipe:: chef_supermarket
#
# Copyright:: 2019, Corey Hemminger
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

chef_supermarket 'supermarket' do
  node['chef_software']['chef_supermarket']&.each do |key, value|
    send(key, value)
  end
  notifies :run, 'execute[reconfigure chef supermarket]', :immediately
end

execute 'reconfigure chef supermarket' do
  command 'supermarket-ctl reconfigure && supermarket-ctl start && supermarket-ctl status'
  live_stream true
  action :nothing
end
