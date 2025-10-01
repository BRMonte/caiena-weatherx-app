class FetchGeocodingService < BaseService
  def self.call(city:)
    return build_error(ERROR_CODES[:validation_error], 'City is required') if city.blank?
    
    Rails.logger.info { "Geocoding request for city: #{city}" }
    
    response = Clients::OpenWeatherClient.make_request(:geocoding, { q: city, limit: 1 })
    error = validate_http_response(response, 'Geocoding')
    return error if error

    ResponseBuilder.new(response, 'Geocoding').parse_geocoding_response
  rescue StandardError => e
    Rails.logger.error { "Geocoding API error for city '#{city}': #{e.message}" }
    build_error(ERROR_CODES[:service_error], 'Unable to find coordinates for the specified city', retryable: true)
  end
end
