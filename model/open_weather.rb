require 'net/http'
require 'uri'

class OpenWeatherApi
  def initialize(zip)
    @zip = zip
    url = "https://api.openweathermap.org/data/2.5/weather?zip=#{@zip},us&appid=#{ENV['open_weather']}&units=imperial"
    @uri = URI(url)
  end

  def get_weather
    begin
      net_response = Net::HTTP.get(@uri)
      parsed_response = JSON.parse(net_response)
      response = "According to OpenWeatherMap.org, the weather in #{parsed_response["name"]} is #{parsed_response["weather"][0]["main"].downcase}. The temperature is #{parsed_response["main"]["temp"].to_i}˚F, and the humidity is at #{parsed_response["main"]["humidity"]}%."
    rescue
      response = "Error: can't get weather for ZIP #{@zip}"
    end
    return response
  end
end
