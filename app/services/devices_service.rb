# frozen_string_literal: true

class DevicesService
  class << self
    def devices
      devices = Rails.application.credentials.devices
      devices.map { |device| Device.new(**device) }
    end

    def by_id(device_id)
      devices = Rails.application.credentials.devices
      device = devices.find { |h| h[:id] == device_id }
      Device.new(**device) if device
    end
  end
end
