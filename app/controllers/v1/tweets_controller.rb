module V1
  class TweetsController < ApplicationController
    def create
      city = params.permit(:city)[:city]
      result = CreateTweetService.call(city: city)
      
      render json: result, status: :created
    end
  end
end
