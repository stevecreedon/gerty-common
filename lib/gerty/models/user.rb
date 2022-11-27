require 'app/aws/dynamodb/cards'
require_relative 'card'

module Gerty
  module Models
    class User

      DONE_SECTION = 4

      def initialize(data)
        @data = data
      end

      def data
        @data
      end

      def id
        @data['id']
      end

      def cards
        @cards ||= owned_cards + co_owned_cards
      end

      def owned_cards
        @owned_cards ||= Gerty::Aws::DynamoDb::Cards.get_owned(kanbanize_user_id).collect{ |card| Gerty::Models::Card.new(card) }
      end

      def co_owned_cards 
        @co_owned_cards ||= Gerty::Aws::DynamoDb::Cards.get_co_owned(kanbanize_user_id).collect{ |card| Gerty::Models::Card.new(card) }
      end

      def active_cards
        cards.select do |card|
          card.kanbanize.section < DONE_SECTION
        end
      end

      def kanbanize_user_id
        @data['kanbanize_user_id']
      end

      def kanbanize
        @kanbanize ||= KanbanizeUser.new(@data['kanbanize'])
      end

    end

    class KanbanizeUser 

      def initialize(kanbanize)
        @kanbanize = kanbanize
      end

      def first_name
        realname.split(" ").first
      end

      def realname
        @kanbanize['realname']
      end

      def user_id
        @kanbanize['user_id']
      end

    end
  end
end