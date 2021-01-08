module Api
  class InternetController < Api::ApiController
    def is_enabled
      id = params[:id]

      enabled = InternetService.is_internet_enabled?(id)

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
