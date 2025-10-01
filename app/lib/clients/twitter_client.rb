# app/lib/clients/twitter_client.rb
module Clients
  class TwitterClient < BaseService
    def self.post_tweet(text)
      return build_error(ERROR_CODES[:validation_error], 'Tweet text is required') if text.blank?
      
      Rails.logger.info { "Posting tweet: #{text[0..50]}..." }
      
      client = initialize_client
      response = client.post("tweets", { text: text }.to_json)
      
      Rails.logger.info { "Tweet posted successfully" }
      {
        success: true,
        tweet_id: response["data"]["id"],
        text: response["data"]["text"]
      }
    rescue StandardError => e
      Rails.logger.error { "Twitter API error: #{e.message}" }
      build_error(ERROR_CODES[:service_error], "Unable to post tweet: #{e.message}", retryable: true)
    end

    private

    def self.initialize_client
      X::Client.new(
        api_key: ENV['TWITTER_API_KEY'],
        api_key_secret: ENV['TWITTER_API_KEY_SECRET'],
        access_token: ENV['TWITTER_ACCESS_TOKEN'],
        access_token_secret: ENV['TWITTER_ACCESS_TOKEN_SECRET']
      )
    end
  end
end