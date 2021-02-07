# frozen_string_literal: true

class InternetService
  class << self
    def internet_enabled?(device)
      connect_to_api do |api|
        address = api.find_address(device.name)
        !address.enabled
      end
    end

    def enable_internet(device, enable)
      connect_to_api do |api|
        address = api.find_address(device.name)

        api.disable_address(address.id, enable) # FYI: Address must be disabled to enable Internet
      end
    end

    private

    def connect_to_api(&block)
      api = MikrotikApi.new(**Rails.application.credentials.mikrotik_api)
      begin
        api.open

        block.call(api) if block_given?
      ensure
        api.close
      end
    end
  end
end
