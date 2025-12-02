# frozen_string_literal: true

module Watchtower
  class Configuration
    # Proc that resolves the current actor (e.g. logged-in user).
    # Called within request context so it has access to controller state.
    # Example: config.current_actor { Current.user }
    attr_reader :current_actor_resolver

    # List of exception class names to ignore and never record.
    # Example: config.ignored_exceptions << "ActionController::RoutingError"
    attr_reader :ignored_exceptions

    # Proc used to authorize access to the dashboard.
    # Evaluated in controller context so you can call any controller method.
    # Example: config.dashboard_auth { authenticate_admin! }
    attr_reader :dashboard_auth_proc

    def initialize
      @current_actor_resolver = nil
      @ignored_exceptions = [
        # "ActionController::RoutingError",
        # "ActionController::UnknownFormat"
      ]
      @dashboard_auth_proc = nil
    end

    def current_actor(&block)
      @current_actor_resolver = block
    end

    def dashboard_auth(&block)
      @dashboard_auth_proc = block
    end
  end
end
