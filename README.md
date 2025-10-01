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

## Performance Approach

### Current Performance
- **Synchronous Processing** - Simple, predictable execution
- **Direct API Calls** - No intermediate caching

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
result = CreateTweetService.call(city: 'London')
```

#### Test Individual Services
```ruby
weather_report = BuildWeatherReportService.call(city: 'London')
puts weather_report

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
```
