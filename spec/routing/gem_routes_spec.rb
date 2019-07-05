# frozen_string_literal: true

require 'spec_helper'

describe 'Gem routes', type: :routing do
  it {
    expect(post: '/auth/create_token').to route_to(
      controller: 'secretkeeper/auth', action: 'create_token'
    )
  }

  it {
    expect(post: '/auth/refresh_token').to route_to(
      controller: 'secretkeeper/auth', action: 'refresh_token'
    )
  }
end
