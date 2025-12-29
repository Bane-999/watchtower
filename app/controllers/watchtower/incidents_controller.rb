# frozen_string_literal: true

module Watchtower
  class IncidentsController < ApplicationController
    def index
      @incidents = Incident.order(occurred_at: :desc)
      if params[:severity].present?
        @incidents = @incidents.where(severity: params[:severity])
      end
      @incidents = @incidents.where(status: params[:status]) if params[:status].present?
      @incidents = paginate(@incidents)

      @open_count     = Incident.open.count
      @resolved_count = Incident.resolved.count
      @critical_count = Incident.critical.count
    end

    def show
      @incident = Incident.find(params[:id])
    end

    def resolve
      @incident = Incident.find(params[:id])

      if @incident.resolve!
        redirect_to incidents_path, notice: 'Incident resolved.'
      else
        redirect_to incident_path(@incident), alert: 'Incident is already resolved.'
      end
    end

    private

    def paginate(scope)
      return scope.page(params[:page]).per(25) if scope.respond_to?(:page)

      scope.limit(25)
    end
  end
end
