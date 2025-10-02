# WeatherX - Weather Tweet Generator

A Rails application that fetches weather data and posts formatted weather reports to Twitter/X.

## Core Functionality

### Weather Services
- **`Location::FetchGeocodingService`** - Converts city names to coordinates
- **`Weather::FetchCurrentWeatherService`** - Gets current weather data  
- **`Weather::FetchWeatherForecastService`** - Gets 5-day weather forecast
- **`Weather::BuildWeatherReportService`** - Combines data into readable report
- **`SocialNetwork::CreateTweetService`** - Orchestrates the flow

### External API Clients
- **`Clients::OpenWeatherClient`** - Handles all OpenWeatherMap API calls
- **`Clients::TwitterClient`** - Handles Twitter/X API interactions

### Utility Classes
- **`BaseService`** - Common error handling, validation, and utilities
- **`ResponseBuilder`** - Parses API responses
- **`ForecastCalculator`** - Calculates daily temperature averages
- **`CacheStore`** - Manages Rails-based caching and rate limiting

## Performance & Reliability Features

### Caching System
- **Coordinates**: Cached for 24 hours (rarely change)
- **Current Weather**: Cached for 30 minutes (frequent updates)
- **Weather Forecast**: Cached for 2 hours (moderate updates)
- **Tweets**: Cached for 2 hours (prevents duplicate posts)

### Rate Limiting & Circuit Breaker
- **API Rate Limiting**: Prevents exceeding OpenWeatherMap's 60 calls/minute limit
- **Circuit Breaker**: Temporarily disables geocoding service after failures (5-minute cooldown)
- **Graceful Degradation**: Services continue working despite partial failures

### Error Handling
- **Standardized Error Format**: Consistent error structure across all services
- **Retry Logic**: Configurable retry for transient failures
- **Comprehensive Logging**: Detailed error tracking and debugging
- **Input Validation**: All inputs validated before processing

## Architecture

### Service-Oriented Design
- **Single Responsibility**: Each service handles one specific task
- **Dependency Injection**: Services depend on abstractions, not concrete classes
- **Stateless Services**: No shared state between requests
- **Modular Design**: Easy to test, maintain, and scale

### Namespaced Organization
- **`Location::`** - Geocoding services
- **`Weather::`** - Weather data services  
- **`SocialNetwork::`** - Social media services
- **`Clients::`** - External API clients

## Dependencies

### Core Stack
- **Rails 7.2.2**
- **Ruby 3.1.2**

### External APIs
- **OpenWeatherMap API** - Weather data source
- **Twitter/X API** - Social media posting (OAuth 1.0a)

### Development & Testing
- **RSpec** - Testing framework
- **VCR** - HTTP request recording/replaying
- **WebMock** - HTTP request mocking
- **Dotenv** - Environment variable management

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

### Usage

#### Start Rails Console
```bash
rails console
```

#### Test Individual Services
```ruby
# Get weather report
weather_report = Weather::BuildWeatherReportService.call(city: 'London')
puts weather_report

# Post custom tweet
tweet_result = Clients::TwitterClient.post_tweet("Weather report")
puts tweet_result[:tweet_id]
```

### Running Tests
```bash
# Run all tests
bundle exec rspec

# Run specific test files
bundle exec rspec spec/services/social_network/create_tweet_service_spec.rb
bundle exec rspec spec/lib/clients/twitter_client_spec.rb
```

