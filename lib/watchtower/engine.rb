# frozen_string_literal: true

module Watchtower
  class Engine < ::Rails::Engine
    engine_name 'watchtower'

    isolate_namespace Watchtower

    initializer 'watchtower.append_migrations' do |app|
      unless app.root.to_s == root.to_s
        app.config.paths['db/migrate'].concat(
          config.paths['db/migrate'].expanded
        )
      end
    end
  end
end
