require 'rails_helper'

RSpec.describe FetchCurrentWeatherService do
  describe '.call' do
    context 'with valid city' do
      it 'returns current weather for London', :vcr do
        result = FetchCurrentWeatherService.call(city: 'London')

        expect(result).to be_a(Hash)
        expect(result[:temperature]).to be_a(Float)
        expect(result[:condition]).to be_a(String)
        expect(result[:humidity]).to be_a(Integer)
        expect(result[:city]).to eq('London')
        expect(result[:country]).to be_a(String)
      end

      it 'returns current weather for Paris', :vcr do
        result = FetchCurrentWeatherService.call(city: 'Paris')

        expect(result).to be_a(Hash)
        expect(result[:temperature]).to be_a(Float)
        expect(result[:condition]).to be_a(String)
        expect(result[:humidity]).to be_a(Integer)
        expect(result[:city]).to eq('Palais-Royal')
        expect(result[:country]).to be_a(String)
      end
    end

    context 'with blank city' do
      it 'returns validation error for empty string' do
        result = FetchCurrentWeatherService.call(city: '')

        expect(result).to be_a(Hash)
        expect(result).to have_key(:error)
        expect(result[:error][:code]).to eq('VALIDATION_ERROR')
        expect(result[:error][:message]).to eq('City is required')
        expect(result[:error][:retryable]).to be false
      end

      it 'returns validation error for nil' do
        result = FetchCurrentWeatherService.call(city: nil)

        expect(result).to be_a(Hash)
        expect(result).to have_key(:error)
        expect(result[:error][:code]).to eq('VALIDATION_ERROR')
        expect(result[:error][:message]).to eq('City is required')
        expect(result[:error][:retryable]).to be false
      end
    end

    context 'when geocoding service fails' do
      it 'returns geocoding error for invalid city', :vcr do
        result = FetchCurrentWeatherService.call(city: 'NonExistentCity12345')

        expect(result).to be_a(Hash)
        expect(result).to have_key(:error)
        expect(result[:error][:code]).to eq('GEOCODING_ERROR')
        expect(result[:error][:message]).to eq('Unable to find coordinates for the specified city')
        expect(result[:error][:retryable]).to be false
      end
    end
  end
end
