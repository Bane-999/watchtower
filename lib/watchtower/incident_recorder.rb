# frozen_string_literal: true

require 'digest'

module Watchtower
  class IncidentRecorder
    def self.record(exception, context: {})
      new(exception, context).record
    end

    def initialize(exception, context = {})
      @exception = exception
      @context   = context
    end

    def record
      return if ignored?

      Incident.create!(
        exception_class: @exception.class.name,
        exception_message: @exception.message,
        backtrace: @exception.backtrace&.join("\n"),
        fingerprint: fingerprint,
        severity: 'medium',
        status: 'open',
        actor_type: actor_type,
        actor_id: actor_id,
        request_url: @context[:request_url],
        request_method: @context[:request_method],
        controller: @context[:controller],
        action: @context[:action],
        ip_address: @context[:ip_address],
        user_agent: @context[:user_agent],
        params: @context.fetch(:params, {}),
        metadata: @context.fetch(:metadata, {}),
        occurred_at: Time.current
      )
    rescue StandardError => e
      warn "[Watchtower] Failed to record incident: #{e.message}"
    end

    private

    def ignored?
      Watchtower.configuration.ignored_exceptions.include?(@exception.class.name)
    end

    def fingerprint
      location = @exception.backtrace&.first || 'unknown'
      Digest::MD5.hexdigest("#{@exception.class.name}#{@exception.message}#{location}")
    end

    def actor
      resolver = Watchtower.configuration.current_actor_resolver
      return nil unless resolver

      resolver.call
    rescue StandardError
      nil
    end

    def actor_type
      @context[:actor]&.class&.name || actor&.class&.name
    end

    def actor_id
      a = @context[:actor] || actor
      a.respond_to?(:id) ? a.id : nil
    end
  end
end
