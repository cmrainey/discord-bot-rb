require_relative 'open_weather'

class Command

  def initialize(event)
    @event = event
    @message = event.content
    command_text = @message.split(" ")[0]
    if command_text[0] == "!"
      @command = command_text.gsub("!", "")
    else
      @command = nil
    end
  end

  def execute
    if self.respond_to?(@command)
      self.public_send(@command)
    else
      puts "Can't execute #{@command}"
    end
  end

  def roll
    # simple dice roller takes a command in the form "xdy" where x is the number of dice and y is
    # the number of faces, e.g. 1d20 or 8d6
    dice = @message.gsub("!roll ", "")
    if /\d+d\d+/.match(dice)
      dice_arr = dice.split("d")
      number = dice_arr[0].to_i
      die = dice_arr[1].to_i
      rolls = []
      roll_total = 0
      number.times do
        roll = rand(1..die)
        roll_total += roll
        rolls << roll
      end
      text = "You rolled #{roll_total} #{rolls}"
    else
      text = "Invalid dice roll request."
    end
    return text
  end

  def progressbar
    # calculates the perctange elapsed of the current year and posts an ACII art progress bar
    today = Date.today
    days_this_year = Date.new(today.year, 12, 31).yday
    pct_done = (100.0 * today.yday / days_this_year).round
    pct_not = 100 - pct_done
    bar = "["
    (pct_done / 2).round.times do
      bar << "|"
    end
    (pct_not / 2).round.times do
      bar << " "
    end
    bar << "]"
    text = "#{today.strftime("%Y")} is \n#{bar} #{pct_done}%\n complete."
    return "`" + text + "`"
  end

  def babyprogress
    today = Date.today
    baby_start = Date.new(2020,11,20)
    baby_finish = Date.new(2021,8,23)
    baby_pct = (( ( today - baby_start ) / ( baby_finish - baby_start ) ).to_f * 100).round(1)
    baby_pct_not = 100.0 - baby_pct
    bar = "["
    (baby_pct / 6).round.times do
      bar << "👶"
    end
    (baby_pct_not / 6).round.times do
      bar << "__"
    end
    bar << "]"
    return "Baby is " + baby_pct.to_s + "\% complete!\n" + "`" + bar + "`"
  end

  def weather
    # gets the current weather at a given 5-digit ZIP code from the OpenWeather API
    # see open_weath_api.rb for the API wrapper class
    zip = @message.gsub("!weather ", "").to_i.to_s
    if zip.length < 5
      zeroes = 5 - zip.length
      zeroes.times do
        zip = "0" + zip
      end
    end
    weather = OpenWeatherApi.new(zip)
    text = weather.get_weather
    return text
  end

  def createchannel
    args = @event.content.split(" ")
    if args[1] != nil
      name = args[1]
      if args[2] != nil && args[2] == "private"
        role = @event.server.roles.find { |r| r.name == '@everyone' }
        
        overwrites = []
        overwrites << Discordrb::Overwrite.new(role.id, type: 'role', allow: 0, deny: 1024)
        overwrites << Discordrb::Overwrite.new(@event.message.author.id, type: "member", allow: 139653860417, deny: 0)
        
        @event.message.mentions.each do |u|
          overwrites << Discordrb::Overwrite.new(u.id, type: "member", allow: 139653860417, deny: 0)
        end

        channel = @event.server.create_channel(name, parent: @event.channel.parent_id, permission_overwrites: overwrites)
        response = "Successfully created new private channel #{channel.name}!"
      else
        channel = @event.server.create_channel(name, parent: @event.channel.parent_id)
        response = "Successfully created new channel #{channel.name}!"
      end
    else
      response = "Error: I need a channel name to create one."
    end
    return response
  end

end