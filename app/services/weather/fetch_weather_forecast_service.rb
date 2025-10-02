module Weather
  class FetchWeatherForecastService < BaseService
    def self.call(city:)
      return build_error(ERROR_CODES[:validation_error], 'City is required') if city.blank?
      
      Rails.logger.info { "Weather forecast request for city: #{city}" }

      if CacheStore.is_fresh?(city, :forecast)
        cached_data = CacheStore.get(city)
        return cached_data[:forecast] if cached_data&.dig(:forecast)
      end

      coordinates = Location::FetchGeocodingService.call(city: city)

      if coordinates[:error]
        return build_error(ERROR_CODES[:geocoding_error], coordinates[:error][:message], retryable: false)
      end
      
      response = Clients::OpenWeatherClient.make_request(:forecast, {
        lat: coordinates[:latitude],
        lon: coordinates[:longitude]
      })
      error = validate_http_response(response, 'Weather Forecast')
      return error if error

      ResponseBuilder.new(response, 'Weather Forecast').parse_forecast_response
    rescue StandardError => e
      Rails.logger.error { "FetchWeatherForecastService failed for '#{city}': #{e.message}" }
      build_error(ERROR_CODES[:service_error], "Unable to fetch weather forecast: #{e.message}", retryable: true)
    end
  end
end
