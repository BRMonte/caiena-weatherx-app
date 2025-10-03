require 'net/http'
require 'json'

module OpenWeatherSdk
  class Client
    BASE_URLS = {
      geocoding:       'http://api.openweathermap.org/geo/1.0/direct',
      current_weather: 'https://api.openweathermap.org/data/2.5/weather',
      forecast:        'https://api.openweathermap.org/data/2.5/forecast'
    }.freeze

    def self.make_request(endpoint, params = {})
      uri = URI(BASE_URLS[endpoint])
      uri.query = URI.encode_www_form(params.merge(appid: OpenWeatherSdk.configuration.api_key))
      
      Rails.logger.debug { "Making #{endpoint} request to: #{uri}" } if defined?(Rails)
      Net::HTTP.get_response(uri)
    end

    def self.parse_response(response, service_name)
      unless response.is_a?(Net::HTTPSuccess)
        Rails.logger.error { "#{service_name} API error: #{response.code} #{response.message}" } if defined?(Rails)
        return build_error(
          'API_ERROR', 
          "#{service_name} API error: #{response.code} #{response.message}", 
          retryable: response.code.to_i >= 500
        )
      end

      JSON.parse(response.body)
    rescue JSON::ParserError => e
      Rails.logger.error { "JSON parsing error: #{e.message}" } if defined?(Rails)
      build_error('PARSING_ERROR', 'Invalid JSON response from API', retryable: false)
    end

    private

    def self.build_error(code, message, retryable: false)
      {
        error: {
          code: code,
          message: message,
          retryable: retryable,
          timestamp: Time.current.iso8601
        }
      }
    end
  end
end
