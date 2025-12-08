# frozen_string_literal: true

FactoryBot.define do
  factory :watchtower_incident, class: 'Watchtower::Incident' do
    exception_class   { 'RuntimeError' }
    exception_message { 'something went wrong' }
    fingerprint       { SecureRandom.hex(8) }
    severity          { 'medium' }
    status            { 'open' }
    occurred_at       { Time.current }
    request_url       { '/some/path' }
    request_method    { 'GET' }
    metadata          { {} }
  end
end
