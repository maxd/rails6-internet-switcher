# frozen_string_literal: true

module Api
  class InternetController < Api::ApiController
    def status
      id = params[:id]

      enabled = InternetService.internet_enabled?(id)

      render json: { enabled: enabled }
    end

    def enable
      id = params[:id]
      enable = ActiveModel::Type::Boolean.new.cast(params[:enable])

      enabled = InternetService.enable_internet(id, enable)

      render json: { enabled: enabled }
    end
  end
end
