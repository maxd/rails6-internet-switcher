# frozen_string_literal: true

class MikrotikApi
  def initialize(host:, user:, password:, verbose: false)
    @host = host
    @user = user
    @password = password

    MTik.verbose = verbose
  end

  def open
    return if @connection

    @connection = MTik::Connection.new(host: @host, user: @user, pass: @password, unencrypted_plaintext: true)
  end

  def close
    return unless @connection

    @connection.close
    @connection = nil
  end

  def find_address(comment)
    raise StandardError, 'Connection closed!' unless @connection

    response = @connection.get_reply('/ip/firewall/address-list/print', "?comment=#{comment}")
    body = response.find_sentence('!re')
    raise StandardError, 'Address not found' unless body

    id = body['.id']
    enabled = !ActiveModel::Type::Boolean.new.cast(body['disabled'])

    OpenStruct.new(id: id, enabled: enabled)
  end

  def disable_address(address_id, disable)
    raise StandardError, 'Connection closed!' unless @connection

    response = @connection.get_reply('/ip/firewall/address-list/set', "=.id=#{address_id}", "=disabled=#{disable}")
    trap = response.find_sentence('!trap')
    raise StandardError, trap['message'] if trap

    disable
  end
end
