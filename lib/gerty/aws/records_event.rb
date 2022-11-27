module Gerty
  module Aws
    class RecordsEvent
      
      def initialize(aws_event)
        @aws_event = aws_event
      end

      def event_source_arn
        @arn ||= @aws_event["Records"].first["eventSourceARN"]
      end

      def records
        aws_records.collect do |record|
          Records.record(record)
        end
      end

      private

      def aws_records
        @aws_event["Records"]
      end
    end

    module Records

      def self.record(record)
        case record["eventSource"]
        when "aws:dynamodb"
          DynamoDb.new(record)
        else
          raise "unexpected event source #{record["eventSource"]}"
        end
      end

      class DynamoDb
        def initialize(record)
          @record = record
        end

        def keys
          @record['dynamodb']['Keys']
        end

        def id 
          keys['id']['S']
        end

        def event_name
          @record['eventName']
        end
      end
    end
  end
end