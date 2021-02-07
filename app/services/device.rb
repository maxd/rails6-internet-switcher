# frozen_string_literal: true

class Device
  attr_accessor :id, :name, :enabled

  def initialize(id:, name:)
    @id = id
    @name = name
    @enabled = InternetService.internet_enabled?(self)
  end

  def internet_enabled?
    @enabled
  end

  def enable_internet!(enable)
    @enabled = InternetService.enable_internet(self, enable)
  end
end
