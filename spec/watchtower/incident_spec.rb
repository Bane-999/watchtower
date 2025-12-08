# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Watchtower::Incident do
  subject(:incident) { build(:watchtower_incident) }

  describe 'validations' do
    it { is_expected.to be_valid }

    it 'requires exception_class' do
      incident.exception_class = nil
      expect(incident).not_to be_valid
    end

    it 'requires exception_message' do
      incident.exception_message = nil
      expect(incident).not_to be_valid
    end

    it 'requires fingerprint' do
      incident.fingerprint = nil
      expect(incident).not_to be_valid
    end

    it 'rejects unknown severity' do
      incident.severity = 'unknown'
      expect(incident).not_to be_valid
    end

    it 'rejects unknown status' do
      incident.status = 'pending'
      expect(incident).not_to be_valid
    end
  end

  describe 'immutability' do
    let(:persisted) { create(:watchtower_incident) }

    it 'raises on update' do
      expect { persisted.update!(exception_message: 'changed') }
        .to raise_error(Watchtower::ImmutableRecordError)
    end

    it 'raises on destroy' do
      expect { persisted.destroy! }
        .to raise_error(Watchtower::ImmutableRecordError)
    end
  end

  describe '#resolve!' do
    let(:persisted) { create(:watchtower_incident) }

    it 'transitions status to resolved' do
      persisted.resolve!
      expect(persisted.reload.status).to eq('resolved')
    end

    it 'sets resolved_at timestamp' do
      persisted.resolve!
      expect(persisted.reload.resolved_at).to be_present
    end

    it 'returns false when already resolved' do
      persisted.resolve!
      expect(persisted.resolve!).to eq(false)
    end
  end

  describe 'scopes' do
    before do
      create(:watchtower_incident, status: 'open',     severity: 'critical')
      create(:watchtower_incident, status: 'resolved', severity: 'low')
    end

    it '.open returns only open incidents' do
      expect(described_class.open.count).to eq(1)
    end

    it '.resolved returns only resolved incidents' do
      expect(described_class.resolved.count).to eq(1)
    end

    it '.critical returns only critical incidents' do
      expect(described_class.critical.count).to eq(1)
    end
  end
end
