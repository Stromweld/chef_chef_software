module ChefSoftware
  module Helpers
    def get_iam_user(user, token)
      Mash.new(JSON.parse(shell_out("curl --insecure -s -H \"api-token: #{token}\" https://localhost/apis/iam/v2/users/#{user}").stdout))
    end

    def get_iam_policy(policy_name, token)
      Mash.new(JSON.parse(shell_out("curl --insecure -s -H \"api-token: #{token}\" https://localhost/apis/iam/v2/policies/#{policy_name}").stdout))
    end

    def kitchen_api_token(name)
      shell_out("chef-automate iam token create #{name} --admin").stdout.strip
    end
  end
end

Chef::DSL::Universal.include(ChefSoftware::Helpers)
