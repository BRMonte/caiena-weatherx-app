module SocialNetwork
  class CreateTweetService < BaseService
    def self.call(city:)
      return build_error(ERROR_CODES[:validation_error], 'City is required') if city.blank?
      
      Rails.logger.info { "Creating weather tweet for city: #{city}" }

      if CacheStore.is_fresh?(city, :tweet)
        cached_data = CacheStore.get(city)
        return cached_data[:tweet] if cached_data&.dig(:tweet)
      end

      weather_report = Weather::BuildWeatherReportService.call(city: city)
      if weather_report.is_a?(Hash) && weather_report[:error]
        return build_error(ERROR_CODES[:service_error], weather_report[:error][:message], retryable: false)
      end

      tweet_result = Clients::TwitterClient.post_tweet(weather_report)
      if tweet_result[:error]
        return build_error(ERROR_CODES[:service_error], tweet_result[:error][:message], retryable: true)
      end
      
      Rails.logger.info { "Weather tweet posted successfully for #{city}" }
      {
        success: true,
        city: city,
        weather_report: weather_report,
        tweet_id: tweet_result[:tweet_id],
        tweet_text: tweet_result[:text]
      }
    rescue StandardError => e
      Rails.logger.error { "CreateTweetService failed for '#{city}': #{e.message}" }
      build_error(ERROR_CODES[:service_error], "Unable to create weather tweet: #{e.message}", retryable: true)
    end
  end
end
