require 'rails_helper'

RSpec.describe V1::TweetsController, type: :request do
  describe 'POST #create', :vcr do
    it 'creates a weather tweet successfully' do
      post '/v1/tweets', params: { city: 'London' }.to_json, headers: { 'Content-Type' => 'application/json' }
      
      expect(response).to have_http_status(:created)
      parsed_response = JSON.parse(response.body)
      expect(parsed_response['success']).to be true
      expect(parsed_response['city']).to eq('London')
      expect(parsed_response['weather_report']).to be_present
      expect(parsed_response).to have_key('tweet_id')
    end
  end
end
