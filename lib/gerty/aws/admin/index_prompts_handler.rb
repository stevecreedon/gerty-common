require 'erb'
require 'json'
require 'gerty/aws/http_event'
require 'gerty/aws/dynamodb/prompt'
require 'gerty/models/column'

module Gerty
  module Aws
    module IndexPromptsHandler

      def self.workflow_prompts(event:, context:)
        http_event = Gerty::Aws::HttpEvent.new(event)
        workflow_key = http_event.query_string["workflow_key"]
        workflow_prompts = Gerty::Aws::DynamoDb::Prompt.workflow_key(workflow_key)
        workflow_prompts_data = []

        workflow_prompts.each do |prompt|
           workflow_prompts_data << prompt
        end
        
        {
            body: workflow_prompts_data.to_json,
            statusCode: 200,
            headers: { "Content-Type" => 'gertylication/json' } 
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
        File.new('gerty/aws/admin/views/prompts/workflow.html.erb').read
      end
    end
  end
end