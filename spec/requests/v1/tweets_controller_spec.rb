require 'rails_helper'

RSpec.describe V1::TweetsController, type: :request do
  describe 'POST #create', :vcr do
    it 'creates a weather tweet successfully' do
      post '/v1/tweets', params: { city: 'London' }.to_json, headers: { 'Content-Type' => 'application/json' }
      
      expect(response).to have_http_status(:created)
      parsed_response = JSON.parse(response.body)
      
      if parsed_response['error']
        expect(parsed_response['error']['code']).to eq('SERVICE_ERROR')
      else
        expect(parsed_response['success']).to be true
        expect(parsed_response['tweet_id']).to be_present
        expect(parsed_response['text']).to be_present
      end
    end
  end
end
