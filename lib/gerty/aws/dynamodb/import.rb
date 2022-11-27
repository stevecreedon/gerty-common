require_relative 'base'

module Gerty
  module Aws
    module DynamoDb
      module Imports
        extend self
        extend Gerty::Aws::DynamoDb::Base    
      
        def oldest(import_type)
          dynamo_resource.client.query({
            table_name: ENV['IMPORTS_TABLE_NAME'],
            index_name: 'ImportedTypeAt',
            key_condition_expression: "#import_type = :import_type",
            expression_attribute_names: {
              '#import_type' => 'import_type'
            },
            expression_attribute_values: {
              ':import_type' => import_type
            },
            limit: 1,
            projection_expression: 'id,args,client'
          }).items
        end


        def imported(id:, imported_at: DateTime.now.iso8601)
          dynamo_resource.client.update_item(
            expression_attribute_names: {
              "#imported_at" => "imported_at" 
            }, 
            expression_attribute_values: {
              ":imported_at" => imported_at
            }, 
            key: {
              "id" => id
            }, 
            return_values: "ALL_NEW", 
            update_expression: "SET #imported_at = :imported_at",
            table_name: ENV['IMPORTS_TABLE_NAME']
          )
        end
      end
    end
  end
end