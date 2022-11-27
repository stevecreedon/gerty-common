require 'logger'

module Gerty
  module Util
    LOGGER = ::Logger.new($stdout)
    case ENV['STAGE']
    when 'development'
      LOGGER.level = Logger::DEBUG
    when 'staging'
      LOGGER.level = Logger::DEBUG
    when 'test'
      LOGGER.level = Logger::WARN
    when 'production'
      LOGGER.level = Logger::INFO
    end
  end
end