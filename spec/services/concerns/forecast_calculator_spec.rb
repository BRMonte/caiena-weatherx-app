require 'rails_helper'

RSpec.describe ForecastCalculator do
  let(:test_class) { Class.new { include ForecastCalculator } }
  let(:calculator) { test_class.new }

  describe '#calculate_daily_averages' do
    let(:forecast_list) do
      [
        {
          'dt_txt' => '2024-01-01 12:00:00',
          'main' => { 'temp' => 300 }
        },
        {
          'dt_txt' => '2024-01-01 15:00:00',
          'main' => { 'temp' => 310 }
        },
        {
          'dt_txt' => '2024-01-02 12:00:00',
          'main' => { 'temp' => 290 }
        },
        {
          'dt_txt' => '2024-01-02 15:00:00',
          'main' => { 'temp' => 295 }
        }
      ]
    end

    before do
      allow(Date).to receive(:current).and_return(Date.parse('2024-01-01'))
    end

    it 'returns daily averages for future dates only' do
      result = calculator.calculate_daily_averages(forecast_list)
      
      expect(result).to be_an(Array)
      expect(result.size).to eq(1)
      expect(result.first[:date]).to eq('2024-01-02')
      expect(result.first[:average_temperature]).to eq(18.85)
    end

    it 'limits results to 5 days' do
      large_forecast_list = (1..10).map do |day|
        {
          'dt_txt' => "2024-01-#{day + 1} 12:00:00",
          'main' => { 'temp' => 300 }
        }
      end

      result = calculator.calculate_daily_averages(large_forecast_list)
      expect(result).to be_an(Array)
      expect(result.size).to eq(5)
    end

    it 'returns empty array when no future forecasts' do
      past_forecast_list = [
        {
          'dt_txt' => '2023-12-31 12:00:00',
          'main' => { 'temp' => 300 }
        }
      ]

      result = calculator.calculate_daily_averages(past_forecast_list)
      expect(result).to be_empty
    end
  end

  describe '#group_forecasts_by_date' do
    let(:forecast_list) do
      [
        { 'dt_txt' => '2024-01-01 12:00:00' },
        { 'dt_txt' => '2024-01-01 15:00:00' },
        { 'dt_txt' => '2024-01-02 12:00:00' }
      ]
    end

    it 'groups forecasts by date' do
      result = calculator.send(:group_forecasts_by_date, forecast_list)
      
      expect(result).to be_a(Hash)
      expect(result.keys).to match_array(['2024-01-01', '2024-01-02'])
      expect(result['2024-01-01']).to be_an(Array)
      expect(result['2024-01-01'].size).to eq(2)
      expect(result['2024-01-02']).to be_an(Array)
      expect(result['2024-01-02'].size).to eq(1)
    end
  end

  describe '#calculate_average_temperature' do
    let(:forecasts) do
      [
        { 'main' => { 'temp' => 300 } },
        { 'main' => { 'temp' => 310 } },
        { 'main' => { 'temp' => 290 } }
      ]
    end

    it 'calculates average temperature in Celsius' do
      result = calculator.send(:calculate_average_temperature, forecasts)
      expect(result).to be_a(Float)
      expect(result).to eq(26.85)
    end

    it 'rounds to 2 decimal places' do
      forecasts_with_decimals = [
        { 'main' => { 'temp' => 300.123 } },
        { 'main' => { 'temp' => 300.456 } }
      ]

      result = calculator.send(:calculate_average_temperature, forecasts_with_decimals)
      expect(result).to be_a(Float)
      expect(result).to eq(27.14)
    end
  end
end
