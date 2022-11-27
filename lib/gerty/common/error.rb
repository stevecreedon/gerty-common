require 'honeybadger'
require 'gerty/aws/dynamodb/import'

module Gerty
  module Common
    module Error 

      def self.try
        begin
          yield
        rescue StandardError => e
          if ENV['HONEYBADGER_API_KEY']
            Honeybadger.notify(e, sync: true, context: error_context(e)) #sync true is important as we have no background worker thread
          else
            raise e
          end
        end
      end

      def self.try_import(import_type)
        begin
          import = Gerty::Aws::DynamoDb::Imports.oldest(import_type).first
          raise "unable to find import for import_type '#{ import_type }'" unless import
          yield import
          Gerty::Aws::DynamoDb::Imports.imported(id: import['id'])
        rescue StandardError => e
          if ENV['HONEYBADGER_API_KEY']
            Honeybadger.notify(e, sync: true, context: error_context(e)) #sync true is important as we have no background worker thread
          else
            raise e
          end
        end
      end

      def self.error_context(e)
        return nil unless e.respond_to?(:context)
        if e.context.is_a?(Hash)
          e.context
        elsif e.context.respond_to?(:params)
          e.context.params 
        end
      end
    end
  end
end