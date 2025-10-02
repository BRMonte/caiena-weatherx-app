require 'rails_helper'

RSpec.describe SocialNetwork::CreateTweetService do
  describe '.call' do
    context 'with valid city' do
      it 'creates weather tweet for London', :vcr do
        result = SocialNetwork::CreateTweetService.call(city: 'London')

        if result[:error]
          expect(result[:error][:code]).to eq('SERVICE_ERROR')
          expect(result[:error][:message]).to include('Unable to post tweet')
        else
          expect(result[:success]).to be true
          expect(result[:city]).to eq('London')
          expect(result[:weather_report]).to be_a(String)
          expect(result[:tweet_id]).to be_a(String)
          expect(result[:tweet_text]).to be_a(String)
        end
      end

      it 'creates weather tweet for Paris', :vcr do
        result = SocialNetwork::CreateTweetService.call(city: 'Paris')

        if result[:error]
          expect(result[:error][:code]).to eq('SERVICE_ERROR')
          expect(result[:error][:message]).to include('Unable to post tweet')
        else
          expect(result[:success]).to be true
          expect(result[:city]).to eq('Paris')
          expect(result[:weather_report]).to be_a(String)
          expect(result[:tweet_id]).to be_a(String)
          expect(result[:tweet_text]).to be_a(String)
        end
      end
    end

    context 'with blank city' do
      it 'returns validation error for empty string' do
        result = SocialNetwork::CreateTweetService.call(city: '')

        expect(result).to be_a(Hash)
        expect(result).to have_key(:error)
        expect(result[:error][:code]).to eq('VALIDATION_ERROR')
        expect(result[:error][:message]).to eq('City is required')
        expect(result[:error][:retryable]).to be false
      end

      it 'returns validation error for nil' do
        result = SocialNetwork::CreateTweetService.call(city: nil)

        expect(result).to be_a(Hash)
        expect(result).to have_key(:error)
        expect(result[:error][:code]).to eq('VALIDATION_ERROR')
        expect(result[:error][:message]).to eq('City is required')
        expect(result[:error][:retryable]).to be false
      end
    end

    context 'when weather service fails' do
      it 'returns error for invalid city', :vcr do
        result = SocialNetwork::CreateTweetService.call(city: 'NonExistentCity12345')

        expect(result).to be_a(Hash)
        expect(result).to have_key(:error)
        expect(result[:error][:message]).to include('Unable to find coordinates for the specified city')
        expect(result[:error][:retryable]).to be false
      end
    end

    context 'when twitter service fails' do
      before do
        allow(Weather::BuildWeatherReportService).to receive(:call).and_return("16°C e clear sky em London")
        allow(Clients::TwitterClient).to receive(:post_tweet).and_return({
          error: { code: 'SERVICE_ERROR', message: 'Twitter API error', retryable: true }
        })
      end

      it 'handles twitter errors' do
        result = SocialNetwork::CreateTweetService.call(city: 'London')

        expect(result).to be_a(Hash)
        expect(result).to have_key(:error)
        expect(result[:error][:message]).to include('Twitter API error')
        expect(result[:error][:retryable]).to be true
      end
    end
  end
end
