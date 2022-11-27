require 'json'
require 'openssl'

module Gerty
  module Aws
    class HttpEvent

      def initialize(aws_event)
        @aws_event = aws_event
      end
    
      def api_data
        JSON.parse(body)
      end

      def command_data
        require 'cgi'
        raw = CGI.parse(body)
        data = {}
        raw.each do |key, value|
          if value.length > 1
            data[key] = value
          else
            data[key] = value.first
          end
        end
        data
      end

      def form_data
        FormParams.new(command_data).params
      end

      def interaction_data
        json = unescape(body.gsub(/^payload=/,""))
        JSON.parse(json)
      end

      def body
        if @aws_event['isBase64Encoded']
          require 'base64'
          Base64.decode64(@aws_event['body'])
        else
          @aws_event['body']
        end
      end

      def authenticated?
        calculated_signature == signature
      end

      def query_string
        @aws_event['queryStringParameters']
      end

      private

      def unescape(body)
        require 'cgi'
        CGI.unescape(body)
      end

      def timestamp
        @aws_event['headers']['x-slack-request-timestamp']
      end

      def signature
        @aws_event['headers']['x-slack-signature']
      end

      def raw_body
        @aws_event['body']
      end

      def calculated_signature
        "v0=#{hexdigest}"
      end

      def hexdigest
        OpenSSL::HMAC.hexdigest(
          "SHA256", 
          ENV['SLACK_SIGNED_SECRET'], 
          base
        )
      end

      def base
        "v0:#{timestamp}:#{body}"
      end

    end

    class FormParams
        
      def initialize(params)
        @params = params
      end
      
      def args
        @args ||= {}
      end
      
      def params
        @params.each do |key, value|
          build_arg(key, value)
        end
        args
      end

      def build_arg(key, value)
        keys = Keys.new(key)
        chain = keys.root_keys.inject(args) do |memo, root_key|
          memo[root_key] ||= {}
          memo[root_key]
        end
        chain[keys.last_key] ||= []
        # Always adding value as an array is the 'Rails Way'
        # That can also cope with checkboxes that have inputs with the same name
        # intended to be an array
        chain[keys.last_key] << value unless value.empty?
      end

      class Keys

        MATCH = /\]\[|\]|\[/

        attr_accessor :last_key, :root_keys

        def initialize(key)
          @key = key
          @root_keys = @key.split(MATCH)
          @last_key = @root_keys.pop
        end

      end
    end
  end
end
