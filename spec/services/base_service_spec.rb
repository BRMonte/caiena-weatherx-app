require 'rails_helper'

RSpec.describe BaseService do
  let(:test_service) { Class.new(BaseService) }

  describe 'ERROR_CODES' do
    it 'contains all expected error codes' do
      expect(BaseService::ERROR_CODES).to be_a(Hash)
      expect(BaseService::ERROR_CODES[:validation_error]).to eq('VALIDATION_ERROR')
      expect(BaseService::ERROR_CODES[:geocoding_error]).to eq('GEOCODING_ERROR')
      expect(BaseService::ERROR_CODES[:current_weather_error]).to eq('CURRENT_WEATHER_ERROR')
      expect(BaseService::ERROR_CODES[:forecast_error]).to eq('FORECAST_ERROR')
      expect(BaseService::ERROR_CODES[:api_error]).to eq('API_ERROR')
      expect(BaseService::ERROR_CODES[:parsing_error]).to eq('PARSING_ERROR')
      expect(BaseService::ERROR_CODES[:service_error]).to eq('SERVICE_ERROR')
    end

    it 'is frozen' do
      expect(BaseService::ERROR_CODES).to be_frozen
    end
  end

  describe '.build_error' do
    it 'builds error hash with required fields' do
      result = test_service.send(:build_error, 'TEST_ERROR', 'Test message')
      
      expect(result).to be_a(Hash)
      expect(result).to have_key(:error)
      expect(result[:error]).to be_a(Hash)
      expect(result[:error][:code]).to eq('TEST_ERROR')
      expect(result[:error][:message]).to eq('Test message')
      expect(result[:error][:service]).to eq(test_service.name)
      expect(result[:error][:retryable]).to be false
      expect(result[:error][:timestamp]).to be_a(String)
    end

    it 'sets retryable to true when specified' do
      result = test_service.send(:build_error, 'TEST_ERROR', 'Test message', retryable: true)
      expect(result[:error][:retryable]).to be true
    end

    it 'includes ISO8601 timestamp' do
      result = test_service.send(:build_error, 'TEST_ERROR', 'Test message')
      timestamp = result[:error][:timestamp]
      
      expect { Time.iso8601(timestamp) }.not_to raise_error
    end
  end

  describe '.service_name' do
    it 'returns the class name' do
      expect(test_service.send(:service_name)).to eq(test_service.name)
    end
  end

  describe '.validate_http_response' do
    let(:success_response) { double('Net::HTTPSuccess', is_a?: true, code: '200', message: 'OK') }
    let(:error_response) { double('Net::HTTPError', is_a?: false, code: '404', message: 'Not Found') }
    let(:server_error_response) { double('Net::HTTPServerError', is_a?: false, code: '500', message: 'Internal Server Error') }

    it 'returns nil for successful responses' do
      result = test_service.send(:validate_http_response, success_response, 'TestService')
      expect(result).to be_nil
    end

    it 'returns error hash for failed responses' do
      result = test_service.send(:validate_http_response, error_response, 'TestService')
      
      expect(result).to be_a(Hash)
      expect(result).to have_key(:error)
      expect(result[:error][:code]).to eq('API_ERROR')
      expect(result[:error][:message]).to include('TestService API error: 404 Not Found')
      expect(result[:error][:retryable]).to be false
    end

    it 'sets retryable to true for server errors' do
      result = test_service.send(:validate_http_response, server_error_response, 'TestService')
      expect(result[:error][:retryable]).to be true
    end
  end

  describe '.parse_json_safely' do
    it 'parses valid JSON' do
      json_string = '{"test": "value"}'
      result = test_service.send(:parse_json_safely, json_string, 'TestService')
      
      expect(result).to be_a(Hash)
      expect(result['test']).to eq('value')
    end

    it 'returns error hash for invalid JSON' do
      invalid_json = 'invalid json'
      result = test_service.send(:parse_json_safely, invalid_json, 'TestService')
      
      expect(result).to be_a(Hash)
      expect(result).to have_key(:error)
      expect(result[:error][:code]).to eq('PARSING_ERROR')
      expect(result[:error][:message]).to eq('Invalid JSON response from API')
      expect(result[:error][:retryable]).to be false
    end
  end
end