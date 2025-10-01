require 'rails_helper'

RSpec.describe Clients::TwitterClient do
  describe '.post_tweet' do
    context 'with valid text' do
      it 'posts tweet successfully', :vcr do
        result = Clients::TwitterClient.post_tweet("Test tweet from RSpec")

        expect(result).to be_a(Hash)
        expect(result[:success]).to be true
        expect(result[:tweet_id]).to be_a(String)
        expect(result[:text]).to eq("Test tweet from RSpec")
      end

      it 'posts weather report tweet', :vcr do
        weather_text = "16°C e clear sky em London em 01/01. Média para os próximos dias: 18°C em 02/01, 20°C em 03/01."
        result = Clients::TwitterClient.post_tweet(weather_text)

        expect(result).to be_a(Hash)
        expect(result[:success]).to be true
        expect(result[:tweet_id]).to be_a(String)
        expect(result[:text]).to eq(weather_text)
      end
    end

    context 'with blank text' do
      it 'returns validation error for empty string' do
        result = Clients::TwitterClient.post_tweet("")

        expect(result).to be_a(Hash)
        expect(result).to have_key(:error)
        expect(result[:error][:code]).to eq('VALIDATION_ERROR')
        expect(result[:error][:message]).to eq('Tweet text is required')
        expect(result[:error][:retryable]).to be false
      end

      it 'returns validation error for nil' do
        result = Clients::TwitterClient.post_tweet(nil)

        expect(result).to be_a(Hash)
        expect(result).to have_key(:error)
        expect(result[:error][:code]).to eq('VALIDATION_ERROR')
        expect(result[:error][:message]).to eq('Tweet text is required')
        expect(result[:error][:retryable]).to be false
      end
    end

    context 'with API errors' do
      before do
        stub_request(:post, /api\.x\.com/)
          .to_return(status: 401, body: '{"errors":[{"code":89,"message":"Invalid or expired token."}]}')
      end

      it 'handles authentication errors' do
        result = Clients::TwitterClient.post_tweet("Test tweet")

        expect(result).to be_a(Hash)
        expect(result).to have_key(:error)
        expect(result[:error][:code]).to eq('SERVICE_ERROR')
        expect(result[:error][:message]).to include('Unable to post tweet')
        expect(result[:error][:retryable]).to be true
      end
    end
  end
end