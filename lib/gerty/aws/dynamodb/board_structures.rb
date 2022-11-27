require_relative 'base'

module Gerty
  module Aws
    module DynamoDb
      module BoardStructure
        extend self
        extend Gerty::Aws::DynamoDb::Base

        def upsert_board_structure(
          subdomain:, 
          board_id:, 
          board_structure:, 
          imported_at: DateTime.now.iso8601
        )
          id = "#{subdomain}-#{board_id}"
          board_structure['imported_at'] = imported_at
          
          dynamo_resource.client.update_item({
            table_name: ENV['BOARD_STRUCTURES_TABLE_NAME'],
            key: { id: id },
            update_expression: 'SET kanbanize = :kanbanize',
            expression_attribute_values: { 
              ':kanbanize': board_structure
            }   
          })
        end
      end
    end
  end
end