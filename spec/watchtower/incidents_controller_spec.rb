# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Watchtower incidents', type: :request do
  before { Watchtower.reset_configuration! }

  describe 'GET /watchtower/incidents' do
    before do
      create(
        :watchtower_incident,
        exception_class: 'OpenIncidentError',
        exception_message: 'Open incident message',
        status: 'open',
        severity: 'high'
      )

      create(
        :watchtower_incident,
        exception_class: 'ResolvedIncidentError',
        exception_message: 'Resolved incident message',
        status: 'resolved',
        severity: 'low'
      )

      create(
        :watchtower_incident,
        exception_class: 'CriticalIncidentError',
        exception_message: 'Critical incident message',
        status: 'open',
        severity: 'critical'
      )
    end

    it 'returns http success' do
      get '/watchtower/incidents'

      expect(response).to have_http_status(:ok)
    end

    it 'renders the incidents list and summary counts' do
      get '/watchtower/incidents'

      expect(response.body).to include(
        'OpenIncidentError',
        'ResolvedIncidentError',
        'CriticalIncidentError'
      )

      summary_text = response_text(response.body)

      expect(summary_text).to include('Open', 'Resolved', 'Critical')
      expect(summary_text).to include('2', '1')
    end

    it 'filters by severity' do
      get '/watchtower/incidents', params: { severity: 'critical' }

      expect(response.body).to include('CriticalIncidentError')
      expect(response.body).not_to include('OpenIncidentError')
      expect(response.body).not_to include('ResolvedIncidentError')
    end

    it 'filters by status' do
      get '/watchtower/incidents', params: { status: 'resolved' }

      expect(response.body).to include('ResolvedIncidentError')
      expect(response.body).not_to include('OpenIncidentError')
      expect(response.body).not_to include('CriticalIncidentError')
    end
  end

  describe 'GET /watchtower/incidents/:id' do
    let!(:incident) do
      create(
        :watchtower_incident,
        exception_class: 'ShownIncidentError',
        exception_message: 'Shown incident message'
      )
    end

    it 'returns http success' do
      get "/watchtower/incidents/#{incident.id}"

      expect(response).to have_http_status(:ok)
    end

    it 'renders the incident details' do
      get "/watchtower/incidents/#{incident.id}"

      expect(response.body).to include('ShownIncidentError', 'Shown incident message')
    end
  end

  describe 'PATCH /watchtower/incidents/:id/resolve' do
    let!(:incident) do
      create(:watchtower_incident, status: 'open')
    end

    it 'resolves the incident' do
      patch "/watchtower/incidents/#{incident.id}/resolve"

      expect(incident.reload.status).to eq('resolved')
    end

    it 'redirects to index' do
      patch "/watchtower/incidents/#{incident.id}/resolve"

      expect(response).to redirect_to('/watchtower/incidents')
    end

    it 'redirects back to the incident when already resolved' do
      incident.resolve!

      patch "/watchtower/incidents/#{incident.id}/resolve"

      expect(response).to redirect_to("/watchtower/incidents/#{incident.id}")
    end
  end

  def response_text(body)
    Nokogiri::HTML.parse(body).text.squish
  end
end
