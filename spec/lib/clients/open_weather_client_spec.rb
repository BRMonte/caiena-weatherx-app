require 'rails_helper'

RSpec.describe Clients::OpenWeatherClient do
  describe 'BASE_URLS' do
    it 'contains all expected endpoints' do
      expect(Clients::OpenWeatherClient::BASE_URLS).to be_a(Hash)
      expect(Clients::OpenWeatherClient::BASE_URLS[:geocoding]).to eq('http://api.openweathermap.org/geo/1.0/direct')
      expect(Clients::OpenWeatherClient::BASE_URLS[:current_weather]).to eq('https://api.openweathermap.org/data/2.5/weather')
      expect(Clients::OpenWeatherClient::BASE_URLS[:forecast]).to eq('https://api.openweathermap.org/data/2.5/forecast')
    end

    it 'is frozen' do
      expect(Clients::OpenWeatherClient::BASE_URLS).to be_frozen
    end
  end

  describe '.make_request' do
    let(:endpoint) { :geocoding }
    let(:params) { { q: 'London', limit: 1 } }

    it 'returns HTTP response' do
      allow(ENV).to receive(:[]).with('WEATHER_API_KEY').and_return('test_key')
      allow(Net::HTTP).to receive(:get_response).and_return(double('response'))

      result = Clients::OpenWeatherClient.make_request(endpoint, params)

      expect(result).to be_a(Object)
    end

    it 'handles different endpoints' do
      allow(ENV).to receive(:[]).with('WEATHER_API_KEY').and_return('test_key')
      allow(Net::HTTP).to receive(:get_response).and_return(double('response'))

      Clients::OpenWeatherClient.make_request(:current_weather, { lat: 1, lon: 2 })
      Clients::OpenWeatherClient.make_request(:forecast, { lat: 1, lon: 2 })

      expect(Net::HTTP).to have_received(:get_response).twice
    end
  end

  describe '.parse_response' do
    let(:service_name) { 'TestService' }
    let(:success_response) { double('Net::HTTPSuccess', is_a?: true, body: '{"test": "value"}') }
    let(:error_response) { double('Net::HTTPError', is_a?: false, code: '404', message: 'Not Found') }
    let(:server_error_response) { double('Net::HTTPServerError', is_a?: false, code: '500', message: 'Internal Server Error') }

    it 'parses JSON for successful responses' do
      result = Clients::OpenWeatherClient.parse_response(success_response, service_name)
      
      expect(result).to be_a(Hash)
      expect(result['test']).to eq('value')
    end

    it 'returns error hash for failed responses' do
      result = Clients::OpenWeatherClient.parse_response(error_response, service_name)
      
      expect(result).to be_a(Hash)
      expect(result).to have_key(:error)
      expect(result[:error][:code]).to eq('API_ERROR')
      expect(result[:error][:retryable]).to be false
    end

    it 'sets retryable to true for server errors' do
      result = Clients::OpenWeatherClient.parse_response(server_error_response, service_name)
      expect(result[:error][:retryable]).to be true
    end

    it 'returns error hash for invalid JSON' do
      invalid_json_response = double('Net::HTTPSuccess', is_a?: true, body: 'invalid json')
      
      result = Clients::OpenWeatherClient.parse_response(invalid_json_response, service_name)
      
      expect(result).to be_a(Hash)
      expect(result).to have_key(:error)
      expect(result[:error][:code]).to eq('PARSING_ERROR')
      expect(result[:error][:retryable]).to be false
    end
  end
end