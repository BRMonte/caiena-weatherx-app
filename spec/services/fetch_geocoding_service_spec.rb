require 'rails_helper'

RSpec.describe FetchGeocodingService do
  describe '.call' do
    context 'with valid city' do
      it 'returns coordinates for London', :vcr do
        result = FetchGeocodingService.call(city: 'London')

        expect(result).to be_a(Hash)
        expect(result[:latitude]).to be_a(Float)
        expect(result[:longitude]).to be_a(Float)
        expect(result[:city]).to eq('London')
        expect(result[:country]).to be_a(String)
      end

      it 'returns coordinates for Paris', :vcr do
        result = FetchGeocodingService.call(city: 'Paris')

        expect(result).to be_a(Hash)
        expect(result[:latitude]).to be_a(Float)
        expect(result[:longitude]).to be_a(Float)
        expect(result[:city]).to eq('Paris')
        expect(result[:country]).to be_a(String)
      end
    end

    context 'with blank city' do
      it 'returns validation error for empty string' do
        result = FetchGeocodingService.call(city: '')

        expect(result).to be_a(Hash)
        expect(result).to have_key(:error)
        expect(result[:error][:code]).to eq('VALIDATION_ERROR')
        expect(result[:error][:message]).to eq('City is required')
        expect(result[:error][:retryable]).to be false
      end

      it 'returns validation error for nil' do
        result = FetchGeocodingService.call(city: nil)

        expect(result).to be_a(Hash)
        expect(result).to have_key(:error)
        expect(result[:error][:code]).to eq('VALIDATION_ERROR')
        expect(result[:error][:message]).to eq('City is required')
        expect(result[:error][:retryable]).to be false
      end
    end

    context 'with invalid city' do
      it 'returns error for non-existent city', :vcr do
        result = FetchGeocodingService.call(city: 'NonExistentCity12345')
      
        expect(result).to be_a(Hash)
        expect(result).to have_key(:error)
        expect(result[:error][:code]).to eq('SERVICE_ERROR')  # Changed from 'API_ERROR'
        expect(result[:error][:message]).to eq('Unable to find coordinates for the specified city')
        expect(result[:error][:retryable]).to be true
      end
    end
  end
end
