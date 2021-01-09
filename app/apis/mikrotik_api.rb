# frozen_string_literal: true

class MikrotikApi
  def initialize(host:, user:, password:, verbose: false)
    @host = host
    @user = user
    @password = password

    MTik.verbose = verbose
  end

  def open
    raise AssertError, 'Connection opened!' if @connection

    @connection = MTik::Connection.new(host: @host, user: @user, pass: @password, unencrypted_plaintext: true)
  rescue MTik::Error => e
    raise ApiError, e.message
  end

  def close
    return unless @connection

    @connection.close
    @connection = nil
  rescue MTik::Error => e
    raise ApiError, e.message
  end

  def find_address(comment)
    raise AssertError, 'Connection closed!' unless @connection

    response = @connection.get_reply('/ip/firewall/address-list/print', "?comment=#{comment}")
    body = response.find_sentence('!re')
    raise ApiError, 'Address not found' unless body

    id = body['.id']
    enabled = !ActiveModel::Type::Boolean.new.cast(body['disabled'])

    OpenStruct.new(id: id, enabled: enabled)
  rescue MTik::Error => e
    raise ApiError, e.message
  end

  def disable_address(address_id, disable)
    raise AssertError, 'Connection closed!' unless @connection

    response = @connection.get_reply('/ip/firewall/address-list/set', "=.id=#{address_id}", "=disabled=#{disable}")
    trap = response.find_sentence('!trap')
    raise ApiError, trap['message'] if trap

    disable
  rescue MTik::Error => e
    raise ApiError, e.message
  end
end
