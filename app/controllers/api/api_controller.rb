# frozen_string_literal: true

module Api
  class ApiController < ActionController::API
    rescue_from ValidationError, ApiError do |exception|
      render status: :internal_server_error, json: { message: exception.message }
    end
  end
end
