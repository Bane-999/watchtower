# frozen_string_literal: true

module Watchtower
  class ApplicationController < ActionController::Base
    before_action :watchtower_auth

    private

    def watchtower_auth
      auth_proc = Watchtower.configuration.dashboard_auth_proc
      return unless auth_proc

      instance_eval(&auth_proc)
    end
  end
end
