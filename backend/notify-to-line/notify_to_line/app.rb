# frozen_string_literal: true

require 'json'
require 'logger'
require 'line/bot'

def logger
  @logger ||= Logger.new($stdout, level: Logger::Severity::INFO)
end

def client
  @client ||= Line::Bot::Client.new do |config|
    config.channel_secret = ENV.fetch('LINE_CHANNEL_SECRET', nil)
    config.channel_token = ENV.fetch('LINE_CHANNEL_TOKEN', nil)
  end
end

def lambda_handler(event:, context:)
  logger.debug(event)
  logger.debug(context)

  puts event
  # client.broadcast({ type: 'text', text: "#{event['']}" })
end
