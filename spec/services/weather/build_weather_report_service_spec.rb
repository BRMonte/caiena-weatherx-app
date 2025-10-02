require 'rails_helper'

RSpec.describe Weather::BuildWeatherReportService do
  describe '.call' do
    context 'with valid city' do
      let(:city) { 'London' }
      let(:current_weather_data) do
        {
          temperature: 15.5,
          condition: 'clear sky',
          city: 'London',
          country: 'GB'
        }
      end
      let(:forecast_data) do
        {
          'list' => [
            {
              'dt_txt' => '2024-01-02 12:00:00',
              'main' => { 'temp' => 300 }
            },
            {
              'dt_txt' => '2024-01-02 15:00:00',
              'main' => { 'temp' => 310 }
            }
          ]
        }
      end

      before do
        allow(Weather::FetchCurrentWeatherService).to receive(:call).with(city: city).and_return(current_weather_data)
        allow(Weather::FetchWeatherForecastService).to receive(:call).with(city: city).and_return(forecast_data)
        allow(Date).to receive(:current).and_return(Date.parse('2024-01-01'))
      end

      it 'returns weather report string' do
        result = Weather::BuildWeatherReportService.call(city: city)

        expect(result).to be_a(String)
        expect(result).to include('16°C e clear sky em London em 01/01')
        expect(result).to include('Média para os próximos dias:')
      end

      it 'calls both weather services' do
        Weather::BuildWeatherReportService.call(city: city)

        expect(Weather::FetchCurrentWeatherService).to have_received(:call).with(city: city)
        expect(Weather::FetchWeatherForecastService).to have_received(:call).with(city: city)
      end
    end

    context 'with blank city' do
      it 'returns validation error' do
        result = Weather::BuildWeatherReportService.call(city: '')

        expect(result).to be_a(Hash)
        expect(result).to have_key(:error)
        expect(result[:error][:code]).to eq('VALIDATION_ERROR')
        expect(result[:error][:message]).to eq('City is required')
        expect(result[:error][:retryable]).to be false
      end
    end

    context 'when current weather service fails' do
      let(:city) { 'London' }
      let(:error_response) do
        {
          error: {
            code: 'API_ERROR',
            message: 'Weather API error',
            retryable: false
          }
        }
      end

      before do
        allow(Weather::FetchCurrentWeatherService).to receive(:call).with(city: city).and_return(error_response)
      end

      it 'returns current weather error' do
        result = Weather::BuildWeatherReportService.call(city: city)

        expect(result).to be_a(Hash)
        expect(result).to have_key(:error)
        expect(result[:error][:code]).to eq('CURRENT_WEATHER_ERROR')
        expect(result[:error][:message]).to eq('Weather API error')
        expect(result[:error][:retryable]).to be false
      end
    end

    context 'when forecast service fails' do
      let(:city) { 'London' }
      let(:current_weather_data) { { temperature: 15.5, condition: 'clear sky', city: 'London' } }
      let(:error_response) do
        {
          error: {
            code: 'API_ERROR',
            message: 'Forecast API error',
            retryable: false
          }
        }
      end

      before do
        allow(Weather::FetchCurrentWeatherService).to receive(:call).with(city: city).and_return(current_weather_data)
        allow(Weather::FetchWeatherForecastService).to receive(:call).with(city: city).and_return(error_response)
      end

      it 'returns forecast error' do
        result = Weather::BuildWeatherReportService.call(city: city)

        expect(result).to be_a(Hash)
        expect(result).to have_key(:error)
        expect(result[:error][:code]).to eq('FORECAST_ERROR')
        expect(result[:error][:message]).to eq('Forecast API error')
        expect(result[:error][:retryable]).to be false
      end
    end

    context 'when service raises exception' do
      let(:city) { 'London' }

      before do
        allow(Weather::FetchCurrentWeatherService).to receive(:call).with(city: city).and_raise(StandardError, 'Network error')
      end

      it 'returns service error' do
        result = Weather::BuildWeatherReportService.call(city: city)

        expect(result).to be_a(Hash)
        expect(result).to have_key(:error)
        expect(result[:error][:code]).to eq('SERVICE_ERROR')
        expect(result[:error][:message]).to include('Unable to build weather report: Network error')
        expect(result[:error][:retryable]).to be true
      end
    end
  end

  describe '.build_report' do
    let(:current_weather) do
      {
        temperature: 15.7,
        condition: 'partly cloudy',
        city: 'Paris'
      }
    end
    let(:daily_averages) do
      [
        { date: '2024-01-02', average_temperature: 18.3 },
        { date: '2024-01-03', average_temperature: 20.1 }
      ]
    end

    before do
      allow(Date).to receive(:current).and_return(Date.parse('2024-01-01'))
    end

    it 'builds formatted weather report' do
      result = Weather::BuildWeatherReportService.send(:build_report, current_weather, daily_averages)

      expect(result).to be_a(String)
      expect(result).to include('16°C e partly cloudy em Paris em 01/01')
      expect(result).to include('Média para os próximos dias: 18°C em 02/01, 20°C em 03/01')
    end

    it 'rounds temperatures' do
      result = Weather::BuildWeatherReportService.send(:build_report, current_weather, daily_averages)

      expect(result).to include('16°C')
      expect(result).to include('18°C')
      expect(result).to include('20°C')
    end
  end
end
