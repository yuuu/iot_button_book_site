# frozen_string_literal: true

require 'json'
require 'logger'
require 'base64'
require 'httpclient'
require 'securerandom'

def logger
  @logger ||= Logger.new($stdout, level: Logger::Severity::DEBUG)
end

def header
  token = ENV.fetch('SWITCHBOT_TOKEN', nil)
  secret = ENV.fetch('SWITCHBOT_SECRET', nil)

  t = (Time.now.to_f * 1000).to_i.to_s
  nonce = SecureRandom.uuid
  sign = Base64.strict_encode64(OpenSSL::HMAC.digest('sha256', secret, "#{token}#{t}#{nonce}"))

  { Authorization: token, sign:, t:, nonce:, 'Content-Type': 'application/json' }
end

def lambda_handler(event:, context:)
  logger.debug(event)
  logger.debug(context)

  device_id = ENV.fetch('SWITCHBOT_DEVICE_ID', nil)

  res = HTTPClient.new.post(
    "https://api.switch-bot.com/v1.1/devices/#{device_id}/commands",
    body: JSON.generate({ command: 'turnOn', parameter: 'default', commandType: 'command' }),
    header:
  )
  puts JSON.parse(res.body.force_encoding('UTF-8'))
end
