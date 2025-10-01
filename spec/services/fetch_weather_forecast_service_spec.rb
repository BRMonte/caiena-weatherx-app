require 'rails_helper'

RSpec.describe FetchWeatherForecastService do
  describe '.call' do
    context 'with valid city' do
      it 'returns forecast data for London', :vcr do
        result = FetchWeatherForecastService.call(city: 'London')

        expect(result).to be_a(Hash)
        expect(result).to have_key('list')
        expect(result['list']).to be_an(Array)
        expect(result['list'].first).to have_key('dt_txt')
        expect(result['list'].first).to have_key('main')
        expect(result['list'].first['main']).to have_key('temp')
      end

      it 'returns forecast data for Paris', :vcr do
        result = FetchWeatherForecastService.call(city: 'Paris')

        expect(result).to be_a(Hash)
        expect(result).to have_key('list')
        expect(result['list']).to be_an(Array)
        expect(result['list'].first).to have_key('dt_txt')
        expect(result['list'].first).to have_key('main')
        expect(result['list'].first['main']).to have_key('temp')
      end
    end

    context 'with blank city' do
      it 'returns validation error for empty string' do
        result = FetchWeatherForecastService.call(city: '')

        expect(result).to be_a(Hash)
        expect(result).to have_key(:error)
        expect(result[:error][:code]).to eq('VALIDATION_ERROR')
        expect(result[:error][:message]).to eq('City is required')
        expect(result[:error][:retryable]).to be false
      end

      it 'returns validation error for nil' do
        result = FetchWeatherForecastService.call(city: nil)

        expect(result).to be_a(Hash)
        expect(result).to have_key(:error)
        expect(result[:error][:code]).to eq('VALIDATION_ERROR')
        expect(result[:error][:message]).to eq('City is required')
        expect(result[:error][:retryable]).to be false
      end
    end

    context 'when geocoding service fails' do
      it 'returns geocoding error for invalid city', :vcr do
        result = FetchWeatherForecastService.call(city: 'NonExistentCity12345')

        expect(result).to be_a(Hash)
        expect(result).to have_key(:error)
        expect(result[:error][:code]).to eq('GEOCODING_ERROR')
        expect(result[:error][:message]).to eq('Unable to find coordinates for the specified city')
        expect(result[:error][:retryable]).to be false
      end
    end
  end
end
