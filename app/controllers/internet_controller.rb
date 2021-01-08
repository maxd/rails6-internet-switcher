# frozen_string_literal: true

class InternetController < ApplicationController
  def index
    @buttons = Rails.application.credentials.device_ids_to_comments.map { |k, v| OpenStruct.new(id: k, name: v) }
  end
end
