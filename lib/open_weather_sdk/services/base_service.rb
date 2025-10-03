module OpenWeatherSdk
  class BaseService
    ERROR_CODES = {
      validation_error: 'VALIDATION_ERROR',
      geocoding_error: 'GEOCODING_ERROR',
      current_weather_error: 'CURRENT_WEATHER_ERROR',
      forecast_error: 'FORECAST_ERROR',
      api_error: 'API_ERROR',
      parsing_error: 'PARSING_ERROR',
      service_error: 'SERVICE_ERROR'
    }.freeze

    private

    def self.build_error(code, message, retryable: false)
      {
        error: {
          code: code,
          message: message,
          service: service_name,
          retryable: retryable,
          timestamp: Time.current.iso8601
        }
      }
    end

    def self.service_name
      name
    end

    def self.validate_http_response(response, service_name)
      unless response.is_a?(Net::HTTPSuccess)
        log_error("#{service_name} API error: #{response.code} #{response.message}")
        return build_error(
          ERROR_CODES[:api_error], 
          "#{service_name} API error: #{response.code} #{response.message}", 
          retryable: response.code.to_i >= 500
        )
      end
      nil
    end

    def self.parse_json_safely(response_body, service_name)
      JSON.parse(response_body)
    rescue JSON::ParserError => e
      log_error("JSON parsing error: #{e.message}")
      build_error(ERROR_CODES[:parsing_error], 'Invalid JSON response from API', retryable: false)
    end

    def self.log_info(message)
      Rails.logger.info(message) if OpenWeatherSdk.configuration.enable_logging && defined?(Rails)
    end

    def self.log_error(message)
      Rails.logger.error(message) if OpenWeatherSdk.configuration.enable_logging && defined?(Rails)
    end
  end
end
