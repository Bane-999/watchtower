# frozen_string_literal: true

module Watchtower
  class Engine < ::Rails::Engine
    engine_name 'watchtower'

    isolate_namespace Watchtower

    config.generators do |g|
      g.migration = true
    end
  end
end
