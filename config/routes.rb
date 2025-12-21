# frozen_string_literal: true

Watchtower::Engine.routes.draw do
  resources :incidents, only: %i[index show] do
    member do
      patch :resolve
    end
  end

  root to: 'incidents#index'
end
