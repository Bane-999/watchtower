# frozen_string_literal: true

require 'watchtower/version'
require 'watchtower/configuration'
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
  end
end
