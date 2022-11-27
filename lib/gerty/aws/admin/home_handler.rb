require 'erb'

module Gerty
  module Aws
    module HomeHandler

      def self.handle(event:, context:)
        html = ERB.new(view).result(binding)
        {
            body: html,
            statusCode: 200,
            headers: { "Content-Type" => 'text/html' } 
        }
      end

      def self.view
        File.new('app/aws/admin/views/home.html.erb').read
      end

    end
  end
end