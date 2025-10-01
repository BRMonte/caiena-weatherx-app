require 'rails_helper'

RSpec.describe ResponseBuilder do
  let(:service_name) { 'TestService' }
  let(:response_builder) { ResponseBuilder.new(response, service_name) }

  describe '#initialize' do
    let(:response) { double('response', body: '{}') }

    it 'sets response and service_name' do
      expect(response_builder.instance_variable_get(:@response)).to eq(response)
      expect(response_builder.instance_variable_get(:@service_name)).to eq(service_name)
    end
  end

  describe '#parse_geocoding_response' do
    let(:response) { double('response', body: geocoding_json) }

    context 'with valid geocoding data' do
      let(:geocoding_json) do
        '[{"name": "London", "lat": 51.5074, "lon": -0.1278, "country": "GB"}]'
      end

      it 'returns coordinates hash' do
        result = response_builder.parse_geocoding_response

        expect(result).to be_a(Hash)
        expect(result[:latitude]).to eq(51.5074)
        expect(result[:longitude]).to eq(-0.1278)
        expect(result[:city]).to eq('London')
        expect(result[:country]).to eq('GB')
      end
    end

    context 'with empty geocoding data' do
      let(:geocoding_json) { '[]' }

      it 'raises error for empty data' do
        expect { response_builder.parse_geocoding_response }.to raise_error(NameError)
      end
    end

    context 'with invalid JSON' do
      let(:geocoding_json) { 'invalid json' }

      it 'raises error for invalid JSON' do
        expect { response_builder.parse_geocoding_response }.to raise_error(NameError)
      end
    end
  end

  describe '#parse_weather_response' do
    let(:response) { double('response', body: weather_json) }

    context 'with valid weather data' do
      let(:weather_json) do
        '{
          "name": "London",
          "main": {"temp": 15.5, "humidity": 80},
          "weather": [{"description": "clear sky"}],
          "sys": {"country": "GB"}
        }'
      end

      it 'returns weather hash' do
        result = response_builder.parse_weather_response

        expect(result).to be_a(Hash)
        expect(result[:temperature]).to eq(15.5)
        expect(result[:condition]).to eq('clear sky')
        expect(result[:humidity]).to eq(80)
        expect(result[:city]).to eq('London')
        expect(result[:country]).to eq('GB')
      end
    end

    context 'with invalid JSON' do
      let(:weather_json) { 'invalid json' }

      it 'raises error for invalid JSON' do
        expect { response_builder.parse_weather_response }.to raise_error(NameError)
      end
    end
  end

  describe '#parse_forecast_response' do
    let(:response) { double('response', body: forecast_json) }

    context 'with valid forecast data' do
      let(:forecast_json) do
        '{"list": [{"dt": 1234567890, "main": {"temp": 15.5}}]}'
      end

      it 'returns forecast data' do
        result = response_builder.parse_forecast_response

        expect(result).to be_a(Hash)
        expect(result['list']).to be_an(Array)
        expect(result['list'].first['main']['temp']).to eq(15.5)
      end
    end

    context 'with invalid JSON' do
      let(:forecast_json) { 'invalid json' }

      it 'raises error for invalid JSON' do
        expect { response_builder.parse_forecast_response }.to raise_error(NameError)
      end
    end
  end
end
