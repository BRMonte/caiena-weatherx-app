module OpenWeatherSdk
  class ResponseBuilder
    def initialize(response, service_name)
      @response = response
      @service_name = service_name
    end

    def parse_geocoding_response
      data = JSON.parse(@response.body)
      return build_error(ERROR_CODES[:api_error], 'City not found', retryable: false) if data.empty?
      
      coordinates = data.first
      {
        latitude: coordinates['lat'],
        longitude: coordinates['lon'],
        city: coordinates['name'],
        country: coordinates['country']
      }
    rescue JSON::ParserError => e
      Rails.logger.error { "JSON parsing error: #{e.message}" }
      build_error(ERROR_CODES[:parsing_error], 'Invalid JSON response from geocoding API', retryable: false)
    end

    def parse_weather_response
      data = JSON.parse(@response.body)    
      {
        temperature: data['main']['temp'],
        condition: data['weather'].first['description'],
        humidity: data['main']['humidity'],
        city: data['name'],
        country: data['sys']['country']
      }
    rescue JSON::ParserError => e
      Rails.logger.error { "JSON parsing error: #{e.message}" }
      build_error(ERROR_CODES[:parsing_error], 'Invalid JSON response from weather API', retryable: false)
    end

    def parse_forecast_response
      data = JSON.parse(@response.body)
      data
    rescue JSON::ParserError => e
      Rails.logger.error { "JSON parsing error: #{e.message}" }
      build_error(ERROR_CODES[:parsing_error], 'Invalid JSON response from forecast API', retryable: false)
    end
  end
end