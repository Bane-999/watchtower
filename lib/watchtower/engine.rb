# frozen_string_literal: true

module Watchtower
  class Engine < ::Rails::Engine
    engine_name 'watchtower'

    isolate_namespace Watchtower

    initializer 'watchtower.append_migrations',
                before: :load_config_initializers do |app|
      unless app.root.to_s == root.to_s
        app.config.paths['db/migrate'] << root.join('db/migrate').to_s
      end
    end

    initializer 'watchtower.middleware' do |app|
      app.middleware.use Watchtower::Middleware
    end
  end
end
