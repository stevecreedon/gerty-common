require 'erb'
require 'json'
require 'app/aws/http_event'
require 'app/aws/dynamodb/advice'
require 'app/models/column'

module Gerty
  module Aws
    module IndexAdviceHandler

  

      def self.workflow_advice(event:, context:)
        http_event = Gerty::Aws::HttpEvent.new(event)
        workflow_key = http_event.query_string["workflow_key"]
        workflow_advice = Gerty::Aws::DynamoDb::Advice.workflow_key(workflow_key)
        workflow_advice_data = []

        workflow_advice.each do |advice|
           workflow_advice_data << advice
        end
        
        {
            body: workflow_advice_data.to_json,
            statusCode: 200,
            headers: { "Content-Type" => 'application/json' } 
        }
      end

      def self.handle(event:, context:)
        http_event = Gerty::Aws::HttpEvent.new(event)
        workflow_id = http_event.query_string["workflow_id"]
        workflow_key = http_event.query_string["workflow_key"]
        subdomain = http_event.query_string["subdomain"]
        dynamodb_columns = Gerty::Aws::DynamoDb::Columns.workflow_columns(workflow_id)
        columns = dynamodb_columns.collect do |dynamodb_column|
          Gerty::Models::Column.new(dynamodb_column)
        end
      
        html = ERB.new(view).result(binding)
        {
            body: html,
            statusCode: 200,
            headers: { "Content-Type" => 'text/html' } 
        }
      end

      def self.view
        File.new('app/aws/admin/views/advice/workflow.html.erb').read
      end
    end
  end
end