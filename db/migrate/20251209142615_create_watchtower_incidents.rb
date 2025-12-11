# frozen_string_literal: true

class CreateWatchtowerIncidents < ActiveRecord::Migration[7.1]
  def change
    create_table :watchtower_incidents do |t|
      t.string :exception_class,   null: false
      t.string :exception_message, null: false
      t.text   :backtrace

      t.string :fingerprint, null: false

      t.string :severity, null: false, default: 'medium'
      t.string :status,   null: false, default: 'open'

      t.string  :actor_type
      t.bigint  :actor_id

      t.string  :request_url
      t.string  :request_method
      t.string  :controller
      t.string  :action
      t.inet    :ip_address
      t.string  :user_agent
      t.jsonb   :params,   null: false, default: {}

      t.jsonb   :metadata, null: false, default: {}

      t.datetime :occurred_at, null: false
      t.datetime :resolved_at

      t.timestamps null: false
    end

    # for grouping identical errors
    add_index :watchtower_incidents, :fingerprint

    add_index :watchtower_incidents, :severity
    add_index :watchtower_incidents, :status
    add_index :watchtower_incidents, :occurred_at

    add_index :watchtower_incidents, %i[actor_type actor_id]

    # find rows that contain this value inside structured data using gin
    add_index :watchtower_incidents, :metadata, using: :gin
    add_index :watchtower_incidents, :params,   using: :gin
  end
end
