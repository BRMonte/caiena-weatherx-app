require_relative '../../lib/open_weather_sdk'

class CreateTweetService < BaseService
  def self.call(city:)

    OpenWeatherSdk.configure { |config| config.api_key = ENV['WEATHER_API_KEY'] }
    
    weather_report = OpenWeatherSdk.get_weather_report(city)
    return weather_report if weather_report.is_a?(Hash) && weather_report[:error]


    tweet_result = Clients::TwitterClient.post_tweet(weather_report)
    tweet_result[:error] ? tweet_result : tweet_result
  end
end