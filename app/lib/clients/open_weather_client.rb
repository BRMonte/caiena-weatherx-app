module Clients
  class OpenWeatherClient < BaseService
    BASE_URLS = {
      geocoding:       'http://api.openweathermap.org/geo/1.0/direct',
      current_weather: 'https://api.openweathermap.org/data/2.5/weather',
      forecast:        'https://api.openweathermap.org/data/2.5/forecast'
    }.freeze

    def self.make_request(endpoint, params = {})
      rate_limit_error = BaseService.check_api_rate_limit
      return rate_limit_error if rate_limit_error

      uri = URI(BASE_URLS[endpoint])
      uri.query = URI.encode_www_form(params.merge(appid: ENV['WEATHER_API_KEY']))
      
      Rails.logger.debug { "Making #{endpoint} request to: #{uri}" }
      Net::HTTP.get_response(uri)
    end

    def self.parse_response(response, service_name)
      unless response.is_a?(Net::HTTPSuccess)
        Rails.logger.error { "#{service_name} API error: #{response.code} #{response.message}" }
        return build_error(
          ERROR_CODES[:api_error], 
          "#{service_name} API error: #{response.code} #{response.message}", 
          retryable: response.code.to_i >= 500
        )
      end

      JSON.parse(response.body)
    rescue JSON::ParserError => e
      Rails.logger.error { "JSON parsing error: #{e.message}" }
      build_error(ERROR_CODES[:parsing_error], 'Invalid JSON response from API', retryable: false)
    end
  end
end
