require 'gerty/aws/dynamodb/advice'
require 'gerty/aws/dynamodb/prompt'
require 'gerty/aws/dynamodb/columns'

module Gerty
  module Models

    class Column

      def initialize(data)
        @data = data
      end

      def id
        @data['id']
      end
      
      def subdomain
        @data['subdomain']
      end

      def kanbanize
        @kanbanize ||= KanbanizeColumn.new(@data['kanbanize'])
      end

      def owner_advice
        advice && advice['advice']['owner']
      end

      def co_owner_advice
        advice && advice['advice']['co_owner']
      end

      def owner_prompt
        prompt && prompt['prompt']['owner']
      end

      def co_owner_prompt
        prompt && prompt['prompt']['co_owner']
      end

      def board_id
        @data['board_id']
      end

      def advice_id
        @data['advice_id']
      end

      def prompt_id
        @data['prompt_id']
      end

      def advice
        @advice ||= Gerty::Aws::DynamoDb::Advice.get_advice_from_id(advice_id) if advice_id
      end

      def prompt
        @prompt ||= Gerty::Aws::DynamoDb::Prompt.get_prompt_from_id(prompt_id) if prompt_id
      end

      def video?
        advice['video']
      end

      def owner_video
        video? && advice['video']['owner']
      end

      def co_owner_video
        video? && advice['video']['co_owner']
      end

    end

    class KanbanizeColumn

      def initialize(kanbanize)
        @kanbanize = kanbanize
      end

      def name
        @kanbanize['name']
      end
      
      def workflow_name
        @kanbanize['workflow_name']
      end

      def description
        @kanbanize['description']
      end

    end
  end
end