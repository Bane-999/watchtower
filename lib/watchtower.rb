# frozen_string_literal: true

require 'watchtower/version'
require 'watchtower/configuration'
require 'watchtower/incident_recorder'
require 'watchtower/middleware'
require 'watchtower/engine'

module Watchtower
  class Error < StandardError; end
  class ImmutableRecordError < Error; end

  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield configuration
    end

    def reset_configuration!
      @configuration = Configuration.new
    end

    # Public API for manually recording a rescued exception.
    #
    # Usage:
    #   rescue Stripe::CardError => e
    #     Watchtower.record_incident(e, context: { order_id: @order.id })
    #   end
    def record_incident(exception, context: {})
      IncidentRecorder.record(exception, context: context)
    end
  end
end
