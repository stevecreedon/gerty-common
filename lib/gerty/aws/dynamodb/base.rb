require 'aws-sdk-dynamodb'
require 'gerty/common/logger'

module Gerty
  module Aws
    module DynamoDb
      module Base

        @@dynamo_resource = nil 

        def dynamo_resource
          @@dynamo_resource ||= ::Aws::DynamoDB::Resource.new(options)
        end

        def options
          { region: ENV['REGION'] }.tap do |opts|
            opts[:endpoint] = ENV['DYNAMO_ENDPOINT'] if ENV['DYNAMO_ENDPOINT'] 
            opts[:ssl_verify_peer] = (ENV['VERIFY_SSL_PEER'].to_s.downcase != 'false')
          end
        end

      end
    end
  end
end