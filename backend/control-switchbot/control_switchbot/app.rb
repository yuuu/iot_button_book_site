# frozen_string_literal: true

require 'json'
require 'logger'
require 'switchbot'

TEMPERATURE = 20  # 温度
MODE = 5          # モード: 0/1 (auto), 2 (cool), 3 (dry), 4 (fan), 5 (heat)
FAN_SPEED = 1     # 風量: 1 (auto), 2 (low), 3 (medium), 4 (high)
POWER_STATE = :on # 電源: on/off

def logger
  @logger ||= Logger.new($stdout, level: Logger::Severity::INFO)
end

def lambda_handler(event:, context:)
  logger.debug(event)
  logger.debug(context)

  device_id = ENV.fetch('SWITCHBOT_DEVICE_ID', nil)
  token = ENV.fetch('SWITCHBOT_TOKEN', nil)
  secret = ENV.fetch('SWITCHBOT_SECRET', nil)

  client = Switchbot::Client.new(token, secret)

  parameter = "#{TEMPERATURE},#{MODE},#{FAN_SPEED},#{POWER_STATE}"
  client.commands(device_id:, command: { command: :setAll, parameter:, commandType: :command })
end
