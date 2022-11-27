require_relative 'base'

module Gerty
  module Aws
    module DynamoDb
      module Cards
        extend self
        extend Gerty::Aws::DynamoDb::Base
          
        def update_card(client:, card:, imported_at: DateTime.now.iso8601)

          update = ["card = :card", "imported_at = :imported_at", "subdomain = :subdomain"]

          values = {
            ':card' => card,
            ':imported_at' => imported_at,
            ':subdomain' => client
          }

          if card['owner_user_id']
            update << 'owner_id = :owner_id'
            values[':owner_id'] = "#{client}-#{card['owner_user_id']}"
          end

          if card['co_owner_ids'].first
            update << 'co_owner_id = :co_owner_id'
            values[':co_owner_id'] = "#{client}-#{card['co_owner_ids'].first}"
          end

          dynamo_resource.client.update_item({
            table_name: ENV['CARDS_TABLE_NAME'],
            key: { id: "#{client}-#{card['board_id']}-#{card['card_id']}" },
            update_expression: "SET #{ update.join(",") }",
            expression_attribute_values: values
          })
        end

        

        def get_card(id)
          dynamo_resource.client.get_item({
            table_name: ENV['CARDS_TABLE_NAME'],
            key: { "id" => id }
          })['item']
        end

        def get_card_from(client:, board_id:, card_id:)
          get_card("#{client}-#{board_id.to_i}-#{card_id.to_i}")
        end

        def get_owned(kanbanize_user_id)
          items = dynamo_resource.client.query({
            expression_attribute_values: { ":owner_id" => kanbanize_user_id }, 
            key_condition_expression: "owner_id = :owner_id",
            index_name: 'card_owners',
            table_name: ENV['CARDS_TABLE_NAME'],
          })[:items]
          items.collect{|c| get_card(c['id']) }
        end

        def get_co_owned(kanbanize_user_id)
          items = dynamo_resource.client.query({
            expression_attribute_values: { ":co_owner_id" => kanbanize_user_id }, 
            key_condition_expression: "co_owner_id = :co_owner_id",
            index_name: 'card_co_owners',
            table_name: ENV['CARDS_TABLE_NAME'],
          })[:items]
          items.collect{|c| get_card(c['id']) }
        end
      end
    end
  end
end
