require 'discordrb'
require 'dotenv/load'
require_relative 'command'

class DiscordBot
  def run(game)
    @bot = Discordrb::Bot.new token: ENV['token'], client_id: ENV['client_id']
    @bot.run true

    @bot.playing = game

    @bot.message contains: "!" do |event|
      handle_command(event)
    end

    @bot.join
  end

  def handle_command(event)
    command = Command.new(event)
    response = command.execute
    if response != nil
      event.respond(response)
    end
  end
end