module Weather
  class BuildWeatherReportService < BaseService
    
    def self.call(city:)
      return build_error(ERROR_CODES[:validation_error], 'City is required') if city.blank?
      
      Rails.logger.info { "Building weather report for city: #{city}" }

      current_weather = Weather::FetchCurrentWeatherService.call(city: city)
      if current_weather[:error]
        return build_error(ERROR_CODES[:current_weather_error], current_weather[:error][:message], retryable: false)
      end
      
      forecast_data = Weather::FetchWeatherForecastService.call(city: city)
      if forecast_data[:error]
        return build_error(ERROR_CODES[:forecast_error], forecast_data[:error][:message], retryable: false)
      end
      
      daily_averages = ForecastCalculator.calculate_daily_averages(forecast_data['list'])
      build_report(current_weather, daily_averages)
    rescue StandardError => e
      Rails.logger.error { "BuildWeatherReportService failed for '#{city}': #{e.message}" }
      build_error(ERROR_CODES[:service_error], "Unable to build weather report: #{e.message}", retryable: true)
    end
    
    private
    
    def self.build_report(current_weather, daily_averages)
      current_temp = current_weather[:temperature].round
      current_condition = current_weather[:condition]
      current_city = current_weather[:city]
      current_date = Date.current.strftime('%d/%m')
      
      forecast_text = daily_averages.map do |day|
        temp = day[:average_temperature].round
        date = Date.parse(day[:date]).strftime('%d/%m')
        "#{temp}°C em #{date}"
      end.join(', ')
      
      "#{current_temp}°C e #{current_condition} em #{current_city} em #{current_date}. Média para os próximos dias: #{forecast_text}."
    end
  end
end