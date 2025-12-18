# frozen_string_literal: true

require 'digest'

module Watchtower
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      @app.call(env)
    rescue Exception => e # rubocop:disable Lint/RescueException
      record_incident(e, env)
      raise
    end

    private

    def record_incident(exception, env)
      return if ignored?(exception)

      request = ActionDispatch::Request.new(env)

      Incident.create!(
        exception_class: exception.class.name,
        exception_message: exception.message,
        backtrace: exception.backtrace&.join("\n"),
        fingerprint: fingerprint(exception),
        severity: severity(exception),
        status: 'open',
        actor_type: actor_type(env),
        actor_id: actor_id(env),
        request_url: request.url,
        request_method: request.method,
        controller: env['action_dispatch.request.parameters']&.dig(:controller),
        action: env['action_dispatch.request.parameters']&.dig(:action),
        ip_address: request.remote_ip,
        user_agent: request.user_agent,
        params: filtered_params(request),
        metadata: {},
        occurred_at: Time.current
      )
    rescue StandardError => e
      # Never let Watchtower itself crash the app
      warn "[Watchtower] Failed to record incident: #{e.message}"
    end

    def ignored?(exception)
      Watchtower.configuration.ignored_exceptions.include?(exception.class.name)
    end

    def fingerprint(exception)
      location = exception.backtrace&.first || 'unknown'
      Digest::MD5.hexdigest("#{exception.class.name}#{exception.message}#{location}")
    end

    def severity(exception)
      case exception
      when NoMemoryError, ScriptError, SignalException then 'critical'
      when StandardError                               then 'medium'
      else                                                  'high'
      end
    end

    def actor(_env)
      resolver = Watchtower.configuration.current_actor_resolver
      return nil unless resolver

      resolver.call
    rescue StandardError
      nil
    end

    def actor_type(env)
      actor(env)&.class&.name
    end

    def actor_id(env)
      a = actor(env)
      a.respond_to?(:id) ? a.id : nil
    end

    def filtered_params(request)
      request.filtered_parameters.to_h
    rescue StandardError
      {}
    end
  end
end
