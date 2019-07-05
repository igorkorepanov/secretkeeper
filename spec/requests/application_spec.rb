# frozen_string_literal: true

require 'spec_helper'

describe 'Application endpoint', type: :request do
  describe 'GET protected_action' do
    let(:access_token) { 'access_token' }
    let(:user_name) { 'name' }
    let(:user) { create(:user, name: user_name) }
    let(:token) { create(:access_token, owner: user) }

    it 'returns unauthorized when auth header is empty' do
      get '/protected_action'

      expect(response).to have_http_status :unauthorized
    end

    it 'returns unauthorized when auth header has invalid format' do
      headers = { 'Authorization' => "Bearer1 #{token.token}" }
      get '/protected_action', headers: headers

      expect(response).to have_http_status :unauthorized
    end

    it 'returns unauthorized when auth header contains an invalid token' do
      headers = { 'Authorization' => "Bearer #{token.token}_1" }
      get '/protected_action', headers: headers

      expect(response).to have_http_status :unauthorized
    end

    it 'returns ok http status' do
      headers = { 'Authorization' => "Bearer #{token.token}" }
      get '/protected_action', headers: headers

      expect(response).to have_http_status :ok
      expect(response.body).to include_json(
        resource_owner: user_name
      )
    end
  end
end
