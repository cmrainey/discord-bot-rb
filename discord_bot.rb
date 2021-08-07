require 'discordrb'
require 'dotenv/load'
require_relative 'lib/command'

@hal = Discordrb::Bot.new token: ENV['token'], client_id: ENV['client_id']
@hal.run true

@hal.playing = "Pod Bay Doors"

@hal.message contains: "!roll" do |event|
  response = Command.roll(event.content)
  event.respond response
end

@hal.message contains: "!weather" do |event|
  response = Command.weather(event.content)
  event.respond response
end

@hal.message contains: "!progressbar" do |event|
  response = Command.progressbar
  event.respond response
end

@hal.message contains: "!babyprogress" do |event|
  response = Command.babyprogress
  event.respond response
end

@hal.message contains: "!createchannel" do |event|
  Command.create_channel(event)
end

@hal.join