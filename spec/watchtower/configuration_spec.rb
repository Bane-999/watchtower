# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Watchtower' do
  describe Watchtower::Configuration do
    subject(:config) { described_class.new }

    describe 'defaults' do
      it 'has no current_actor_resolver' do
        expect(config.current_actor_resolver).to be_nil
      end

      it 'has no dashboard_auth_proc' do
        expect(config.dashboard_auth_proc).to be_nil
      end

      it 'ignores common Rails routing exceptions by default' do
        expect(config.ignored_exceptions).to eq([])
      end
    end

    describe '#current_actor' do
      it 'stores the block as current_actor_resolver' do
        user = instance_double(Object)
        config.current_actor { user }
        expect(config.current_actor_resolver).to be_a(Proc)
      end
    end

    describe '#dashboard_auth' do
      it 'stores the block as dashboard_auth_proc' do
        config.dashboard_auth { true }
        expect(config.dashboard_auth_proc).to be_a(Proc)
      end
    end
  end

  describe Watchtower do
    describe '.configure' do
      after { described_class.reset_configuration! }

      it 'yields the configuration object' do
        described_class.configure do |config|
          expect(config).to be_a(Watchtower::Configuration)
        end
      end

      it 'persists configuration changes' do
        described_class.configure do |config|
          config.current_actor { 'admin' }
        end

        resolver = described_class.configuration.current_actor_resolver
        expect(resolver.call).to eq('admin')
      end

      it 'can add to ignored_exceptions' do
        described_class.configure do |config|
          config.ignored_exceptions << 'MyApp::CustomError'
        end

        expect(described_class.configuration.ignored_exceptions).to include('MyApp::CustomError')
      end
    end
  end
end
