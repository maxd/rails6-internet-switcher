# frozen_string_literal: true

module Api
  class ApiController < ActionController::API
    before_action :default_format_json
    before_action :authenticate_user!

    rescue_from ValidationError, ApiError do |exception|
      render status: :internal_server_error, json: { message: exception.message }
    end

    protected

    def default_format_json
      request.format = :json
    end
  end
end
