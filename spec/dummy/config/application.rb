# frozen_string_literal: true

require_relative "boot"

require "active_record/railtie"
require "action_controller/railtie"
require "action_view/railtie"

Bundler.require(*Rails.groups)
require "watchtower"

module Dummy
  class Application < Rails::Application
    config.load_defaults 7.1
    config.eager_load = false
  end
end
