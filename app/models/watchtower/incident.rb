# frozen_string_literal: true

module Watchtower
  class Incident < ActiveRecord::Base
    self.table_name = 'watchtower_incidents'

    SEVERITIES = %w[low medium high critical].freeze
    STATUSES = %w[open resolved].freeze

    validates :exception_class, presence: true
    validates :exception_message, presence: true
    validates :fingerprint, presence: true
    validates :severity, inclusion: { in: SEVERITIES }
    validates :status, inclusion: { in: STATUSES }

    scope :open, -> { where(status: 'open') }
    scope :resolved, -> { where(status: 'resolved') }
    scope :critical, -> { where(severity: 'critical') }
    scope :recent, -> { order(occurred_at: :desc) }

    # Incidents are append-only.
    before_update  { raise Watchtower::ImmutableRecordError, 'Watchtower incidents cannot be modified' }
    before_destroy { raise Watchtower::ImmutableRecordError, 'Watchtower incidents cannot be deleted' }

    def resolved?
      status == 'resolved'
    end

    def open?
      status == 'open'
    end

    # Allowed state transition - not a record update in the domain sense.
    # Uses update_columns to bypass ActiveRecord callbacks including the
    # immutability guard above.
    def resolve!
      return false if resolved?

      update_columns(status: 'resolved', resolved_at: Time.current)
    end
  end
end
