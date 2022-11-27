require_relative 'base'
require 'securerandom'
require 'aws-sdk-dynamodb'
require 'app/util/logger'

module Gerty
  module Aws
    module DynamoDb
      module Users
        extend self
        extend Gerty::Aws::DynamoDb::Base

        def set_ownerships(client:, board_id:, kanbanize_user_id:, ownerships:)
          
          id = get_id_from_kanbanize_user_id(client, kanbanize_user_id)

          if id

            begin
              dynamo_resource.client.update_item({
                table_name: ENV['USERS_TABLE_NAME'],
                key: { id: id },
                update_expression: 'SET ownerships = :ownerships',
                expression_attribute_values: {
                  ':ownerships': {}
                },
                condition_expression: "attribute_not_exists(ownerships)"
              })
           rescue ::Aws::DynamoDB::Errors::ConditionalCheckFailedException => e
             Gerty::Util::LOGGER.debug("conditional check for ownerships not existing failed")
           end

            dynamo_resource.client.update_item({
              table_name: ENV['USERS_TABLE_NAME'],
              key: { id: id },
              update_expression: 'SET ownerships.#board_id = :ownerships',
              expression_attribute_values: {
                ':ownerships': ownerships
              },
              expression_attribute_names: {
                '#board_id': board_id.to_s
              }
            })
          else
             Gerty::Util::LOGGER.debug "cannot find id for kanabnize user #{client} #{kanbanize_user_id}"
          end
        end
           
        def update_slack_user(
          client:, 
          slack_user:, 
          imported_at: DateTime.now.iso8601
        )


          unless slack_user['email']
            # can be a bot...
            Gerty::Util::LOGGER.debug("slack user has no email #{slack_user}")
            return
          end

          id = get_id_from_email(slack_user['email']) || SecureRandom.uuid

          slack_user['slack']['imported_at'] = imported_at

          dynamo_resource.client.update_item({
            table_name: ENV['USERS_TABLE_NAME'],
            key: { id: id },
            update_expression: 'SET slack = :slack, email = :email, client = :client, slack_user_id = :slack_user_id',
            expression_attribute_values: {
              ':slack_user_id': slack_user['slack_user_id'],
              ':slack': slack_user['slack'], 
              ":email": slack_user['email'],
              ":client": client
            },
          })
        end

        def update_kanbanize_user(subdomain:, kanbanize_user:, imported_at: DateTime.now.iso8601)
          id = get_id_from_email(kanbanize_user['email']) || SecureRandom.uuid

          kanbanize_user['imported_at'] = imported_at
          kanbanize_user['subdomain'] = subdomain

          dynamo_resource.client.update_item({
            table_name: ENV['USERS_TABLE_NAME'],
            key: { id: id },
            update_expression: 'SET kanbanize_user_id = :user_id, kanbanize = :user, email = :email',
            expression_attribute_values: { 
              ':user': kanbanize_user,
              ':email': kanbanize_user['email'],
              ':user_id': "#{subdomain}-#{kanbanize_user['user_id']}" 
            },
          })
        end

        def get_user(id)
          dynamo_resource.client.get_item({
            table_name: ENV['USERS_TABLE_NAME'],
            key: {"id" => id}
          })['item']
        end
 
        def get_id_from_email(email)
          
          items = dynamo_resource.client.query({
            expression_attribute_values: { ":email" => email }, 
            key_condition_expression: "email = :email",
            index_name: 'email',
            table_name: ENV['USERS_TABLE_NAME'],
          })
           
          case items.items.count
          when 0
            nil
          when 1
            items.items.first['id']
          else
            raise "found more than one user for email #{email}"
          end
        end

        def get_from_kanbanize_user_id(kanbanize_user_id)
          return nil unless kanbanize_user_id
          get_user(get_id_from_kanbanize_user_id(kanbanize_user_id))
        end

        def get_from_email(email)
          id = get_id_from_email(email)
          get_user(id) if id
        end
         
        def get_id_from_kanbanize_user_id(kanbanize_user_id)
          items = dynamo_resource.client.query({
            expression_attribute_values: { ":kanbanize_user_id" => kanbanize_user_id }, 
            key_condition_expression: "kanbanize_user_id = :kanbanize_user_id",
            index_name: 'kanbanize_user_id',
            table_name: ENV['USERS_TABLE_NAME'],
          }) 

          case items.items.count
          when 0
            nil
          when 1
            items.items.first['id']
          else
            raise "found more than one user for kanbanize_user_id #{kanbanize_user_id}"
          end

        end

        def get_from_slack_user_id(slack_user_id)
          get_user(get_id_from_slack_user_id(slack_user_id))
        end

        def get_id_from_slack_user_id(slack_user_id)
          
          items = dynamo_resource.client.query({
            expression_attribute_values: { ":slack_user_id" => slack_user_id }, 
            key_condition_expression: "slack_user_id = :slack_user_id",
            index_name: 'slack_user_id',
            table_name: ENV['USERS_TABLE_NAME'],
          })
           
          case items.items.count
          when 0
            nil
          when 1
            items.items.first['id']
          else
            raise "found more than one user for slack_user_id #{kanbanize_user_id}"
          end
        end
  
      end
    end
  end
end