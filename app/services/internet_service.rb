class InternetService

  @device_ids_to_comments = Rails.application.credentials.device_ids_to_comments.with_indifferent_access

  class << self

    def is_internet_enabled?(device_id)
      raise StandardError.new('Unknown device id') unless @device_ids_to_comments.has_key?(device_id)

      connect_to_api do |api|
        address = api.find_address(@device_ids_to_comments[device_id])
        !address.enabled
      end
    end

    def enable_internet(device_id, enable)
      raise StandardError.new('Unknown device id') unless @device_ids_to_comments.has_key?(device_id)

      connect_to_api do |api|
        address = api.find_address(@device_ids_to_comments[device_id])

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
