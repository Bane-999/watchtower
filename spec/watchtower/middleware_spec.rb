# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Watchtower::Middleware do
  let(:app)        { ->(_env) { [200, {}, ['OK']] } }
  let(:middleware) { described_class.new(app) }
  let(:env)        { Rack::MockRequest.env_for('/test', method: 'GET') }

  describe '#call' do
    context 'when no exception is raised' do
      it 'returns the app response unchanged' do
        status, _, body = middleware.call(env)
        expect(status).to eq(200)
        expect(body).to eq(['OK'])
      end

      it 'does not create an incident' do
        expect { middleware.call(env) }
          .not_to change(Watchtower::Incident, :count)
      end
    end

    context 'when an exception is raised' do
      let(:app) { ->(_env) { raise 'boom' } }

      it 're-raises the exception' do
        expect { middleware.call(env) }.to raise_error(RuntimeError, 'boom')
      end

      it 'creates an incident' do
        expect do
          middleware.call(env)
        rescue StandardError
          nil
        end
          .to change(Watchtower::Incident, :count).by(1)
      end

      it 'records the exception class and message' do
        begin
          middleware.call(env)
        rescue StandardError
          nil
        end
        incident = Watchtower::Incident.last
        expect(incident.exception_class).to eq('RuntimeError')
        expect(incident.exception_message).to eq('boom')
      end

      it 'records a fingerprint' do
        begin
          middleware.call(env)
        rescue StandardError
          nil
        end
        expect(Watchtower::Incident.last.fingerprint).to be_present
      end

      it 'records the request url' do
        begin
          middleware.call(env)
        rescue StandardError
          nil
        end
        expect(Watchtower::Incident.last.request_url).to include('/test')
      end
    end

    context 'when exception is in ignored list' do
      let(:app) { ->(_env) { raise ActionController::RoutingError, 'no route' } }

      before do
        Watchtower.configure do |config|
          config.ignored_exceptions << 'ActionController::RoutingError'
        end
      end

      after { Watchtower.reset_configuration! }

      it 'does not create an incident' do
        expect do
          middleware.call(env)
        rescue StandardError
          nil
        end
          .not_to change(Watchtower::Incident, :count)
      end

      it 'still re-raises the exception' do
        expect { middleware.call(env) }
          .to raise_error(ActionController::RoutingError)
      end
    end
  end
end
