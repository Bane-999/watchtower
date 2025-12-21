# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Watchtower::ApplicationController, type: :controller do
  controller(described_class) do
    def index
      render plain: 'ok'
    end
  end

  describe 'dashboard auth' do
    context 'when no dashboard_auth_proc is configured' do
      before { Watchtower.reset_configuration! }

      it 'allows access' do
        get :index
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when dashboard_auth_proc is configured and passes' do
      before do
        Watchtower.configure do |config|
          config.dashboard_auth { true }
        end
      end

      after { Watchtower.reset_configuration! }

      it 'allows access' do
        get :index
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
