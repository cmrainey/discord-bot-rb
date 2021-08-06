require 'discordrb'
require 'dotenv/load'
require_relative 'lib/command'

@hal = Discordrb::Bot.new token: ENV['token'], client_id: ENV['client_id']
@hal.run true

@hal.game = "Pod Bay Doors"

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
  args = event.content.split(" ")
  if args[0] == "!createchannel"
    if args[1] != nil
      name = args[1]
      if args[2] != nil
        if args[2] == "private"
          role = event.server.roles.find { |r| r.name == '@everyone' }
          overwrites = []
          overwrites << Discordrb::Overwrite.new(role.id, type: 'role', allow: 0, deny: 1024)
          overwrites << Discordrb::Overwrite.new(event.message.author.id, type: "member", allow: 139653860417, deny: 0)
          event.message.mentions.each do |u|
            overwrites << Discordrb::Overwrite.new(u.id, type: "member", allow: 139653860417, deny: 0)
          end
          channel = event.server.create_channel(name, parent: event.channel.parent_id, permission_overwrites: overwrites)
        else
          channel = event.server.create_channel(name, parent: event.channel.parent_id)
        end
      else
        channel = event.server.create_channel(name, parent: event.channel.parent_id)
      end
    else
      event.respond "Error: I need a channel name to create one!"
    end
  else
    event.respond "Error: Invalid channel creation command."
  end
end

@hal.join