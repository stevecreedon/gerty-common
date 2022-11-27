require 'app/aws/dynamodb/users'
require 'app/aws/dynamodb/columns'
require 'date'
require_relative 'user'
require_relative 'column'


module Gerty
  module Models
    class Card

      def initialize(data)
        @data = data
      end

      def data
        @data
      end

      def id
        @data['id']
      end

      def ownership(user)
        case user.kanbanize_user_id
        when co_owner_id
          'co_owner'
        when owner_id
          'owner'
        else
          raise "expected owner or co_owner"
        end
      end
      
      def owner?(user)
        ownership(user) == 'owner'
      end

      def co_owner?(user)
        ownership(user) == 'co_owner'
      end

      def co_owner_id
        @data['co_owner_id']
      end

      def owner_id
        @data['owner_id']
      end

      def co_owner
        @co_owner ||=  begin
         data = Gerty::Aws::DynamoDb::Users.get_from_kanbanize_user_id(@data['co_owner_id'])
         data ? Gerty::Models::User.new(data) : nil
        end
      end

      def owner
        @owner ||=  begin
          data = Gerty::Aws::DynamoDb::Users.get_from_kanbanize_user_id(@data['owner_id'])
          data ? Gerty::Models::User.new(data) : nil
        end
      end

      def column
        @column ||= Gerty::Models::Column.new(
          Gerty::Aws::DynamoDb::Columns.get_column(client: subdomain, 
                                                 board_id: kanbanize.board_id, 
                                                column_id: kanbanize.column_id)
        )
      end

      def subdomain
        @data['subdomain']
      end
      
      def kanbanize
        @kanbanize ||= KanbanizeData.new(@data['card'])
      end
        
      def link
        "https://#{ subdomain }.kanbanize.com/ctrl_board/#{ kanbanize.board_id }/cards/#{ kanbanize.card_id }/details/"
      end

      class KanbanizeData 

        attr_accessor :kanbanize

        def initialize(kanbanize)
          @kanbanize = kanbanize
        end

        def card_id
          @kanbanize['card_id'].to_i
        end

        def board_id
          @kanbanize['board_id'].to_i
        end

        def column_id
          @kanbanize['column_id'].to_i
        end

        def title
          @kanbanize['title']
        end

        def section
          @kanbanize['section'].to_i
        end

        def in_current_position_since
          @kanbanize['in_current_position_since']
        end

        def days
          (DateTime.now - DateTime.parse(in_current_position_since)).to_i
        end
  
      end

    end
  end
end

