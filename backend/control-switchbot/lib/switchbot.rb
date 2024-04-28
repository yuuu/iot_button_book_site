require 'switchbot'

print 'Your SwitchBot token: '
token = gets.chomp

print 'Your SwitchBot secret key: '
secret_key = gets.chomp

puts

client = Switchbot::Client.new(token, secret_key)
res = client.devices
res.dig(:body, :device_list).each do |device|
  puts "Device: #{device[:device_name]} (#{device[:device_id]})"
end
