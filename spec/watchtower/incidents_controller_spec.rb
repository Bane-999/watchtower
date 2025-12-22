# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Watchtower::IncidentsController, type: :controller do
  routes { Watchtower::Engine.routes }

  before { Watchtower.reset_configuration! }

  describe 'GET #index' do
    let!(:open_incident)     { create(:watchtower_incident, status: 'open',     severity: 'high') }
    let!(:resolved_incident) { create(:watchtower_incident, status: 'resolved', severity: 'low') }
    let!(:critical_incident) { create(:watchtower_incident, status: 'open',     severity: 'critical') }

    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:ok)
    end

    it 'assigns @incidents' do
      get :index
      expect(assigns(:incidents)).to include(open_incident, resolved_incident, critical_incident)
    end

    it 'assigns correct counts' do
      get :index
      expect(assigns(:open_count)).to eq(2)
      expect(assigns(:resolved_count)).to eq(1)
      expect(assigns(:critical_count)).to eq(1)
    end

    it 'filters by severity' do
      get :index, params: { severity: 'critical' }
      expect(assigns(:incidents)).to include(critical_incident)
      expect(assigns(:incidents)).not_to include(open_incident)
    end

    it 'filters by status' do
      get :index, params: { status: 'resolved' }
      expect(assigns(:incidents)).to include(resolved_incident)
      expect(assigns(:incidents)).not_to include(open_incident)
    end
  end

  describe 'GET #show' do
    let!(:incident) { create(:watchtower_incident) }

    it 'returns http success' do
      get :show, params: { id: incident.id }
      expect(response).to have_http_status(:ok)
    end

    it 'assigns @incident' do
      get :show, params: { id: incident.id }
      expect(assigns(:incident)).to eq(incident)
    end
  end

  describe 'PATCH #resolve' do
    let!(:incident) { create(:watchtower_incident, status: 'open') }

    it 'resolves the incident' do
      patch :resolve, params: { id: incident.id }
      expect(incident.reload.status).to eq('resolved')
    end

    it 'redirects to index' do
      patch :resolve, params: { id: incident.id }
      expect(response).to redirect_to(incidents_path)
    end

    it 'redirects back with alert when already resolved' do
      incident.resolve!
      patch :resolve, params: { id: incident.id }
      expect(response).to redirect_to(incident_path(incident))
    end
  end
end
