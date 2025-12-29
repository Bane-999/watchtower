# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Watchtower::IncidentRecorder do
  let(:exception) do
    RuntimeError.new('something went wrong').tap do |e|
      e.set_backtrace(['app/controllers/orders_controller.rb:42'])
    end
  end

  describe '.record' do
    it 'creates an incident' do
      expect { Watchtower::IncidentRecorder.record(exception) }
        .to change(Watchtower::Incident, :count).by(1)
    end

    it 'stores exception class and message' do
      Watchtower::IncidentRecorder.record(exception)
      incident = Watchtower::Incident.last
      expect(incident.exception_class).to eq('RuntimeError')
      expect(incident.exception_message).to eq('something went wrong')
    end

    it 'stores the backtrace' do
      Watchtower::IncidentRecorder.record(exception)
      expect(Watchtower::Incident.last.backtrace).to include('orders_controller.rb')
    end

    it 'generates a fingerprint' do
      Watchtower::IncidentRecorder.record(exception)
      expect(Watchtower::Incident.last.fingerprint).to be_present
    end

    it 'generates the same fingerprint for the same exception' do
      Watchtower::IncidentRecorder.record(exception)
      Watchtower::IncidentRecorder.record(exception)
      fingerprints = Watchtower::Incident.last(2).map(&:fingerprint)
      expect(fingerprints.uniq.size).to eq(1)
    end

    it 'stores metadata from context' do
      Watchtower::IncidentRecorder.record(exception, context: { metadata: { order_id: 42 } })
      expect(Watchtower::Incident.last.metadata['order_id']).to eq(42)
    end

    it 'stores request_url from context' do
      Watchtower::IncidentRecorder.record(exception, context: { request_url: '/orders/42' })
      expect(Watchtower::Incident.last.request_url).to eq('/orders/42')
    end
  end
end
