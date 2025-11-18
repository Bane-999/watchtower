# frozen_string_literal: true

RSpec.describe Watchtower do
  it 'has a version number' do
    expect(Watchtower::VERSION).not_to be_nil
  end
end
