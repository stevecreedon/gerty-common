require_relative 'base'
require 'securerandom'

module Gerty
  module Aws
    module DynamoDb
      module Prompt
        extend self
        extend Gerty::Aws::DynamoDb::Base

         # prompt is expectded to be a hash
        # { owner: "owner prompt", co_owner: "co-owner prompt" }
        def upsert_prompt(
          id: SecureRandom.uuid, 
          prompts:,
          column_key:,
          workflow_key:
        )
        
          dynamo_resource.client.update_item({
            table_name: ENV['PROMPTS_TABLE_NAME'],
            key: { id: id },
            update_expression: 'SET prompt = :prompts, column_key = :column_key, workflow_key = :workflow_key, updated_at = :updated_at',
            expression_attribute_values: { 
              ':prompts': prompts,
              ':column_key': column_key,
              ':prompt_key': workflow_key,
              ':updated_at': DateTime.now.iso8601
            }   
          })
        end

        def get_prompt_from_id(prompt_id)
          dynamo_resource.client.get_item({
            table_name: ENV['PROMPTS_TABLE_NAME'],
            key: { "id" => prompt_id }
          })['item']
        end
 
        def workflow_key(workflow_key)
          workflow_key_ids(workflow_key).collect do |index_key|
            get_prompt_from_id(index_key['id'])
          end
        end
        
        def workflow_key_ids(workflow_key)
          dynamo_resource.client.query({
            expression_attribute_values: { ":workflow_key" => workflow_key }, 
            key_condition_expression: "workflow_key = :workflow_key",
            index_name: 'workflow_key',
            table_name: ENV['PROMPTS_TABLE_NAME'], 
          })[:items]
        end
      end
    end
  end
end