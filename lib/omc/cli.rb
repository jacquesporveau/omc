require 'thor'
require 'aws_cred_vault'
require 'aws-sdk'

module Omc
  class Cli < Thor
    desc 'ssh', 'Connect to an instance on a stack on an account'
    def ssh(account, stack)
      iam_account = vault.account account
      user = iam_account.users.first
      ops = ::AWS::OpsWorks::Client.new user.credentials

      ops_stack = get_by_name ops.describe_stacks[:stacks], stack
      instances = ops.describe_instances(stack_id: ops_stack[:stack_id])[:instances]
      instance = instances.first
      system "ssh #{user.name}@#{instance[:public_ip]}"
    end

    private
    def vault
      AwsCredVault::Toml.new File.join(ENV['HOME'], '.aws_cred_vault')
    end

    def get_by_name collection, name
      collection.detect do |x|
        x[:name] == name
      end || abort("Can't find #{name.inspect} among #{collection.map{|x| x[:name] }.inspect}")
    end
  end
end