require_relative 'base'
require 'securerandom'

module Gerty
  module Aws
    module DynamoDb
      module Messages
        extend self
        extend Gerty::Aws::DynamoDb::Base    

        def put_message(key:, data:, command:)
          dynamo_resource.client.put_item({
            table_name: ENV['MESSAGES_TABLE_NAME'],
            item: { id: SecureRandom.uuid, key: key, created_at: DateTime.now.iso8601, data: data, command: command }
          })
        end

        def get_message(id)
          dynamo_resource.client.get_item({
            table_name: ENV['MESSAGES_TABLE_NAME'],
            key: { id: id }
          })['item']
        end

      end
    end
  end
end
    