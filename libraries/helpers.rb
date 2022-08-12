module ChefSoftware
  module Helpers
    def get_iam_user(user)
      Mash.new(JSON.parse(shell_out("curl --insecure -s -H \"api-token: #{node['chef_software']['automate_admin_token']}\" https://localhost/apis/iam/v2/users/#{user}").stdout))
    end

    def get_iam_policy(policy_name)
      Mash.new(JSON.parse(shell_out("curl --insecure -s -H \"api-token: #{node['chef_software']['automate_admin_token']}\" https://localhost/apis/iam/v2/policies/#{policy_name}").stdout))
    end

    def create_iam_user(user_json)
      json = user_json.to_json
      execute "create local user #{user_json['id']}" do
        command "curl --insecure -s -H \"api-token: #{node['chef_software']['automate_admin_token']}\" -H \"Content-Type: application/json\" -d '#{json}' https://localhost/apis/iam/v2/users"
        not_if { user_json['id'].eql?(get_iam_user(user_json['id'])['user']['id'])  }
        #sensitive true
      end
    end

    def create_iam_policy(policy_json)
      json = policy_json.to_json
      test_policy_statements = get_iam_policy(policy_json['id'])['policy']['statements']&.each do |state|
        state.delete('resources')
      end
      execute "generate iam policy #{policy_json['id']}" do
        command "curl --insecure -s -H \"api-token: #{node['chef_software']['automate_admin_token']}\" -H \"Content-Type: application/json\" -d '#{json}' https://localhost/apis/iam/v2/policies"
        not_if {
          policy_json['id'].eql?(get_iam_policy(policy_json['id'])['policy']['id']) &&
          policy_json['members'].eql?(get_iam_policy(policy_json['id'])['policy']['members']) &&
          policy_json['statements'].eql?(test_policy_statements)
        }
        #sensitive true
      end
    end
  end
end

Chef::DSL::Universal.include(ChefSoftware::Helpers)
