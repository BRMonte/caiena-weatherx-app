module V1
  class TweetsController < ApplicationController

    def create
      city = tweet_params[:city]

      result = SocialNetwork::CreateTweetService.call(city: city)

      if result[:error]
        render_error(result)
      else
        render_success(result)
      end
    rescue StandardError => e
      Rails.logger.error { "TweetsController#create failed: #{e.message}" }
      Rails.logger.error { e.backtrace.join("\n") }
      
      render json: {
        error: {
          code: 'INTERNAL_ERROR',
          message: 'An unexpected error occurred. Please try again later.',
          retryable: true,
          timestamp: Time.current.iso8601
        }
      }, status: :internal_server_error
    end

    private

    def tweet_params
      params.permit(:city)
    end


    def render_success(result)
      render json: result, status: :created
    end

    def render_error(result)
      error = result[:error]
      status = determine_http_status(error[:code])

      render json: result, status: status
    end

    def determine_http_status(error_code)
      case error_code
      when 'VALIDATION_ERROR'
        :unprocessable_entity
      when 'GEOCODING_ERROR'
        :not_found
      when 'SERVICE_ERROR', 'API_ERROR'
        :bad_gateway
      when 'RATE_LIMIT_ERROR', 'CIRCUIT_OPEN_ERROR'
        :service_unavailable
      else
        :internal_server_error
      end
    end
  end
end
