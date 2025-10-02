module ForecastCalculator

  def self.calculate_daily_averages(forecast_list)
    grouped_by_date = group_forecasts_by_date(forecast_list)
    
    tomorrow = Date.current + 1.day
    future_forecasts = grouped_by_date.select do |date, forecasts|
      Date.parse(date) >= tomorrow
    end
    
    future_forecasts.map do |date, forecasts|
      {
        date: date,
        average_temperature: calculate_average_temperature(forecasts)
      }
    end.first(5)
  end
  
  private
  
  def self.group_forecasts_by_date(forecast_list)
    forecast_list.group_by do |forecast|
      Date.parse(forecast['dt_txt']).strftime('%Y-%m-%d')
    end
  end
  
  def self.calculate_average_temperature(forecasts)
    temperatures = forecasts.map { |f| f['main']['temp'] }
    average_kelvin = temperatures.sum / temperatures.count
    (average_kelvin - 273.15).round(2)
  end
end
