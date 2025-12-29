# frozen_string_literal: true

RSpec.describe Watchtower do
  it 'has a version number' do
    expect(Watchtower::VERSION).not_to be_nil
  end

  describe '.record_incident' do
    let(:exception) { RuntimeError.new('manual capture') }

    before do
      allow(Watchtower::IncidentRecorder).to receive(:record)
    end

    it 'delegates to IncidentRecorder' do
      Watchtower.record_incident(exception)

      expect(Watchtower::IncidentRecorder).to have_received(:record)
        .with(exception, context: {})
    end

    it 'passes context through' do
      Watchtower.record_incident(exception, context: { order_id: 1 })

      expect(Watchtower::IncidentRecorder).to have_received(:record)
        .with(exception, context: { order_id: 1 })
    end
  end
end
