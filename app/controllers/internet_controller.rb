# frozen_string_literal: true

class InternetController < ApplicationController
  def index
    @devices = DevicesService.devices
  end

  def enable
    id = params[:id]
    enable = ActiveModel::Type::Boolean.new.cast(params[:enable])

    device = DevicesService.by_id(id) or raise ActionController::RoutingError, 'Device not found'
    device.enable_internet!(enable)

    render partial: 'device', locals: { device: device }
  end
end
