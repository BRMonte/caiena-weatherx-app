# README


## Architecture & Design

### Service-Oriented Architecture
- **`FetchGeocodingService`** - Converts city names to coordinates
- **`FetchCurrentWeatherService`** - Gets current weather data
- **`FetchWeatherForecastService`** - Gets 5-day weather forecast
- **`BuildWeatherReportService`** - Combines data into readable report
- **`CreateTweetService`** - Orchestrates the entire flow

### Client Layer
- **`Clients::OpenWeatherClient`** - Handles all OpenWeatherMap API calls
- **`Clients::TwitterClient`** - Handles Twitter/X API interactions

### Utility Classes
- **`BaseService`** - Common error handling and utilities
- **`ResponseBuilder`** - Parses API responses consistently
- **`ForecastCalculator`** - Calculates daily temperature averages

## Dependencies

### Core Rails Stack
- **Rails 7.2.2** - Web framework
- **Ruby 3.1.2** - Programming language
- **Puma** - Web server
- **Bootsnap** - Boot time optimization

### External APIs
- **OpenWeatherMap API** - Weather data source
- **Twitter/X API** - Social media posting

### Development & Testing
- **RSpec** - Testing framework
- **VCR** - HTTP request recording/replaying
- **WebMock** - HTTP request mocking
- **Dotenv** - Environment variable management

### Notable Absences
- **No Database** - Stateless service architecture
- **No Background Jobs** - Synchronous processing
- **No Caching** - Real-time data only

## Scalability Features

### Horizontal Scaling
- **Stateless Services** - No shared state between requests
- **Independent Services** - Each service can be scaled separately
- **API-First Design** - Easy to extract services into microservices

### Performance Optimizations
- **Service Composition** - Reusable components
- **Error Handling** - Graceful degradation
- **Logging** - Comprehensive request tracking
- **VCR Cassettes** - Fast, reliable testing without API calls

### Future Scaling Options
- **Background Jobs** - Move to Sidekiq/Resque for async processing
- **Caching Layer** - Add Redis for weather data caching
- **API Gateway** - Add rate limiting and authentication
- **Microservices** - Extract services into separate applications

## Safety & Reliability

### Comprehensive Testing
- **Unit Tests** - Individual service testing
- **Integration Tests** - End-to-end workflow testing
- **VCR Cassettes** - Real API response testing
- **Error Scenarios** - Invalid inputs, API failures, network issues

### Error Handling
- **Standardized Errors** - Consistent error format across all services
- **Retry Logic** - Configurable retry for transient failures
- **Graceful Degradation** - Service continues working despite partial failures
- **Logging** - Detailed error tracking and debugging

### Security
- **Environment Variables** - API keys stored securely
- **Input Validation** - All inputs validated before processing
- **Rate Limiting** - Respects API rate limits
- **No Sensitive Data Storage** - No database means no data persistence

## Performance Approach

### Current Performance
- **Synchronous Processing** - Simple, predictable execution
- **Direct API Calls** - No intermediate caching
- **Memory Efficient** - Stateless services use minimal memory

### Performance Monitoring
- **Request Logging** - Track execution times
- **Error Tracking** - Monitor failure rates
- **API Response Times** - Monitor external service performance

### Performance Optimizations
- **Service Reuse** - Geocoding results cached within request
- **Efficient Parsing** - Minimal data transformation
- **Connection Pooling** - HTTP connections reused
- **VCR Testing** - Fast test execution without network calls

## How to Run

### Prerequisites
```bash
# Install Ruby 3.1.2
rbenv install 3.1.2
rbenv local 3.1.2

# Install dependencies
bundle install
```

### Environment Setup
Create `.env` file with your API keys:
```bash
# OpenWeatherMap API
WEATHER_API_KEY=your_openweathermap_api_key

# Twitter/X API (OAuth 1.0a)
TWITTER_API_KEY=your_twitter_api_key
TWITTER_API_KEY_SECRET=your_twitter_api_key_secret
TWITTER_ACCESS_TOKEN=your_twitter_access_token
TWITTER_ACCESS_TOKEN_SECRET=your_twitter_access_token_secret
```

### Running the Application

#### Start Rails Console
```bash
rails console
```

#### Create Weather Tweets
```ruby
# Single city
result = CreateTweetService.call(city: 'London')

# Multiple cities
cities = ['London', 'Paris', 'Tokyo', 'New York']
cities.each do |city|
  result = CreateTweetService.call(city: city)
  puts "#{city}: #{result[:success] ? 'Success' : 'Failed'}"
end
```

#### Test Individual Services
```ruby
# Test weather report generation
weather_report = BuildWeatherReportService.call(city: 'London')
puts weather_report

# Test Twitter posting
tweet_result = Clients::TwitterClient.post_tweet("Test tweet")
puts tweet_result
```

### Running Tests
```bash
# Run all tests
bundle exec rspec

# Run specific test files
bundle exec rspec spec/services/create_tweet_service_spec.rb
bundle exec rspec spec/lib/clients/twitter_client_spec.rb

# Run tests with VCR (records real API calls)
bundle exec rspec --tag vcr
```

## API Endpoints

This application is designed as a service library rather than a web application. All functionality is accessed through service classes in the Rails console or can be integrated into other applications.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

## License

This project is part of a technical challenge and is not intended for production use.