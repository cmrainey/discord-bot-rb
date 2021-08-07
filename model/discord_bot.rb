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
    command_text = event.content.split(" ")[0]
    if command_text[0] == "!"
      command_text = command_text.gsub("!", "")
      command = Command.new(event)
      if command.respond_to?(command_text)
        response = command.public_send(command_text)
        event.respond(response)
      end
    end
  end
end