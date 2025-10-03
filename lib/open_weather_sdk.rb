require_relative 'open_weather_sdk/version'
require_relative 'open_weather_sdk/client'
require_relative 'open_weather_sdk/services/base_service'
require_relative 'open_weather_sdk/response_builder'
require_relative 'open_weather_sdk/forecast_calculator'
require_relative 'open_weather_sdk/services/fetch_geocoding_service'
require_relative 'open_weather_sdk/services/fetch_current_weather_service'
require_relative 'open_weather_sdk/services/fetch_weather_forecast_service'
require_relative 'open_weather_sdk/services/build_weather_report_service'

module OpenWeatherSdk
  def self.get_weather_report(city)
    Services::BuildWeatherReportService.call(city: city)
  end

  def self.configure
    yield(configuration)
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  class Configuration
    attr_accessor :api_key, :cache_store, :enable_logging

    def initialize
      @api_key = nil
      @cache_store = nil
      @enable_logging = true
    end
  end
end