# frozen_string_literal: true

require 'json'
require 'logger'
require 'base64'
require 'httpclient'
require 'securerandom'

SWITCHBOT_API = 'https://api.switch-bot.com/v1.1'

TEMPERATURE = 20  # 温度
MODE = 5          # モード: 0/1 (auto), 2 (cool), 3 (dry), 4 (fan), 5 (heat)
FAN_SPEED = 1     # 風量: 1 (auto), 2 (low), 3 (medium), 4 (high)
POWER_STATE = :on # 電源: on/off

def logger
  @logger ||= Logger.new($stdout, level: Logger::Severity::INFO)
end

def header(token, secret)
  t = (Time.now.to_f * 1000).to_i.to_s
  nonce = SecureRandom.uuid
  sign = Base64.strict_encode64(OpenSSL::HMAC.digest('sha256', secret, "#{token}#{t}#{nonce}"))

  { Authorization: token, sign:, t:, nonce:, 'Content-Type': 'application/json; charset=utf8' }
end

def devices(token, secret)
  uri = "#{SWITCHBOT_API}/devices"
  header = header(token, secret)

  res = HTTPClient.new.get(uri, header:)
  logger.info(res.body)
end

def turn_on(token, secret, device_id)
  uri = "#{SWITCHBOT_API}/devices/#{device_id}/commands"
  parameter = "#{TEMPERATURE},#{MODE},#{FAN_SPEED},#{POWER_STATE}"
  body = { command: :setAll, parameter:, commandType: :command }.to_json
  header = header(token, secret)

  res = HTTPClient.new.post(uri, body:, header:)
  logger.info(res.body)
end

def lambda_handler(event:, context:)
  logger.debug(event)
  logger.debug(context)

  device_id = ENV.fetch('SWITCHBOT_DEVICE_ID', nil)
  token = ENV.fetch('SWITCHBOT_TOKEN', nil)
  secret = ENV.fetch('SWITCHBOT_SECRET', nil)

  # デバイスIDを取得する際はコメントアウトを外す
  # devices(token, secret)

  turn_on(token, secret, device_id)
end
