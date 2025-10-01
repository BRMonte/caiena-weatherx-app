class FetchCurrentWeatherService < BaseService
  def self.call(city:)
    return build_error(ERROR_CODES[:validation_error], 'City is required') if city.blank?
    
    Rails.logger.info { "Current weather request for city: #{city}" }
    
    coordinates = FetchGeocodingService.call(city: city)
    if coordinates[:error]
      return build_error(ERROR_CODES[:geocoding_error], coordinates[:error][:message], retryable: false)
    end

    response = Clients::OpenWeatherClient.make_request(:current_weather, {
      lat: coordinates[:latitude],
      lon: coordinates[:longitude],
      units: 'metric'
    })
    error = validate_http_response(response, 'Current Weather')
    return error if error

    ResponseBuilder.new(response, 'Current Weather').parse_weather_response
  rescue StandardError => e
    Rails.logger.error { "Weather service error for city '#{city}': #{e.message}" }
    build_error(ERROR_CODES[:service_error], "Unable to fetch weather data: #{e.message}", retryable: true)
  end
end
