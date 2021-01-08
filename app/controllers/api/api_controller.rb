module Api
  class ApiController < ActionController::API
    rescue_from StandardError do |exception|
      render status: :internal_server_error, json: { message: exception.message }
    end
  end
end
