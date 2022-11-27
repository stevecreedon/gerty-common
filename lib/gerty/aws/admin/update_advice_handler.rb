require 'app/aws/dynamodb/columns'
require 'app/aws/http_event'
require 'app/util/error'

module Gerty
  module Aws
    module UpdateAdviceHandler

      def self.handle(event:, context:)
        Gerty::Util::Error.try do
          Gerty::Util::LOGGER.debug(event)
          http_event = Gerty::Aws::HttpEvent.new(event)

          http_event.form_data['column'].each do | column_id, advice_id |
            if advice_id.first
              Gerty::Aws::DynamoDb::Columns.set_column_advice(
                column_id: column_id, 
                advice_id: advice_id.first
              )
            end
          end
            
          {
            statusCode: 302,
            headers: {
              'Location': '/aws/admin/home',
            }
          }
          
        end
      end
    end
  end
end