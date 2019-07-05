# frozen_string_literal: true

require 'spec_helper'

describe 'Authorization endpoint', type: :request do
  let(:token_expire_time) { 6.hours }

  before do
    allow(Secretkeeper.configuration).to receive(:access_token_expires_in)
      .and_return(token_expire_time)
  end

  describe 'POST create_token' do
    let(:user_name) { 'name' }
    let(:user_password) { 'password' }
    let(:user) { create(:user, name: user_name, password: user_password) }
    let(:post_params) do
      {
        resource_owner: user.class.name,
        name: user_name,
        password: user_password
      }
    end

    it 'returns unauthorized http status code' do
      post '/auth/create_token'
      expect(response).to have_http_status :unauthorized
    end

    it 'creates access_token' do
      post '/auth/create_token', params: post_params

      aggregate_failures do
        expect(Secretkeeper::AccessToken.count).to eq 1

        token = Secretkeeper::AccessToken.first
        expect(token.owner_type).to eq user.class.name
        expect(token.owner_id).to eq user.id
      end
    end

    it 'returns JSON' do
      post '/auth/create_token', params: post_params

      expect(response).to have_http_status :created
      body = JSON.parse(response.body)
      json_expectations(body)
    end
  end

  describe 'POST refresh_token' do
    let(:token) { create(:access_token) }

    it 'returns unauthorized http status code' do
      post '/auth/refresh_token', params: {
        refresh_token: "#{token.refresh_token}_1"
      }

      expect(response).to have_http_status :forbidden
      expect(response.body).to be_empty
    end

    it 'creates new access_token' do
      post '/auth/refresh_token', params: { refresh_token: token.refresh_token }
      expect(Secretkeeper::AccessToken.count).to eq 2
    end

    it 'returns valid JSON' do
      post '/auth/refresh_token', params: { refresh_token: token.refresh_token }

      expect(response).to have_http_status :ok
      body = JSON.parse(response.body)
      json_expectations(body)
    end
  end

  def json_expectations(body)
    token = Secretkeeper::AccessToken.last
    expect(body).to include_json(
      access_token: token.token,
      expires_in: token_expire_time.to_i,
      refresh_token: token.refresh_token,
      created_at: token.created_at.to_i
    )
  end
end
