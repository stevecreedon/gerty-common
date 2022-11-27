require_relative 'base'

module Gerty
  module Aws
    module DynamoDb
      module Columns
        extend self
        extend Gerty::Aws::DynamoDb::Base

        def get_column(client:, board_id:, column_id:)
          id = "#{client}-#{board_id.to_i}-#{column_id.to_i}"
          get_column_from_id(id)
        end

        def get_column_from_id(column_id)
          dynamo_resource.client.get_item({
            table_name: ENV['COLUMNS_TABLE_NAME'],
            key: { "id" => column_id }
          })['item']
        end

        def set_column_advice(column_id:, advice_id:)
         dynamo_resource.client.update_item({
            table_name: ENV['COLUMNS_TABLE_NAME'],
            key: { id: column_id },
            update_expression: 'SET advice_id = :advice_id',
            expression_attribute_values: { 
              ':advice_id': advice_id
            }   
          })
        end

        def set_column_prompt(column_id:, prompt_id:)
          dynamo_resource.client.update_item({
             table_name: ENV['COLUMNS_TABLE_NAME'],
             key: { id: column_id },
             update_expression: 'SET prompt_id = :prompt_id',
             expression_attribute_values: { 
               ':prompt_id': prompt_id
             }   
           })
         end

        def update_kanbanize_column(subdomain:, board_id:, kanbanize_column:, imported_at: DateTime.now.iso8601)
          id = "#{subdomain}-#{board_id}-#{kanbanize_column['column_id']}"
          kanbanize_column['imported_at'] = imported_at
          
         dynamo_resource.client.update_item({
            table_name: ENV['COLUMNS_TABLE_NAME'],
            key: { id: id },
            update_expression: 'SET kanbanize = :kanbanize_column, column_path = :column_path, board_id = :board_id, subdomain = :subdomain, workflow_id = :workflow_id',
            expression_attribute_values: { 
              ':kanbanize_column': kanbanize_column,
              ':column_path': "#{ board_id }/#{ kanbanize_column['workflow_name'] }/#{ kanbanize_column['name'] }",
              ':board_id': board_id.to_s,
              ':subdomain': subdomain,
              ':workflow_id': kanbanize_column['workflow_id'].to_s
            }   
          })
        end

        def update_advice(id, advice)
          dynamo_resource.client.update_item({
            table_name: ENV['COLUMNS_TABLE_NAME'],
            key: { id: id },
            update_expression: 'SET advice = :advice',
            expression_attribute_values: { 
              ':advice': advice
            }   
          })
        end

        def update_prompts(id, prompts)
          dynamo_resource.client.update_item({
            table_name: ENV['COLUMNS_TABLE_NAME'],
            key: { id: id },
            update_expression: 'SET prompts = :prompts',
            expression_attribute_values: { 
              ':prompts': prompts
            }   
          })
        end

        def board_columns(board_id)
          board_column_ids(board_id).collect do |index|
            get_column_from_id(index['id'])
          end
        end

        def board_column_ids(board_id)
          items = dynamo_resource.client.query({
            expression_attribute_values: { ":board_id" => board_id }, 
            key_condition_expression: "board_id = :board_id",
            index_name: 'board_id',
            table_name: ENV['COLUMNS_TABLE_NAME'],
          })[:items] 
        end

        def workflow_columns(workflow_id)
          ids = workflow_column_ids(workflow_id).collect do |index_key|
            get_column_from_id(index_key["id"])
          end
        end

        def workflow_column_ids(workflow_id)
          dynamo_resource.client.query({
            expression_attribute_values: { ":workflow_id" => workflow_id }, 
            key_condition_expression: "workflow_id = :workflow_id",
            index_name: 'workflow_id',
            table_name: ENV['COLUMNS_TABLE_NAME'], 
          })[:items]
        end

        def all
          dynamo_resource.client.scan({
            table_name: ENV['COLUMNS_TABLE_NAME']
          })[:items]
        end

      end
    end
  end
end