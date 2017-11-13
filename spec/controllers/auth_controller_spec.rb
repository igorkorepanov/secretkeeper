require "spec_helper"

RSpec.describe Secretkeeper::AuthController, type: :controller do
  before do
    allow(Secretkeeper.configuration).to receive(:access_token_expires_in).and_return(6.hours)
  end

  context "POST create_token" do
    it "passes params" do
      dummy = mock_model("ResourceOwner")

      Secretkeeper.reflect do |on|
        on.resource_owner do |params|
          dummy.fake_method(params)
        end
      end

      expect(dummy).to receive(:fake_method).with(hash_including(key: "value"))
      post :create_token, params: { key: "value" }
    end

    it "returns 401 http status code" do
      # allow(Secretkeeper).to receive_message_chain(:reflection_resource_owner, :call) { nil }
      Secretkeeper.reflect do |on|
        on.resource_owner do |params|
          nil
        end
      end

      post :create_token
      expect(response).to have_http_status 401
    end

    it "creates access_token" do
      dummy = mock_model("ResourceOwner")
      allow(dummy.class).to receive(:base_class).and_return(dummy.class)

      Secretkeeper.reflect do |on|
        on.resource_owner do |params|
          dummy
        end
      end

      post :create_token

      expect(Secretkeeper::AccessToken.count).to eq 1

      token = Secretkeeper::AccessToken.first

      expect(token.owner_type).to eq "ResourceOwner"
      expect(token.owner_id).to eq dummy.id
    end

    it "returns appropriate JSON" do
      dummy = mock_model("ResourceOwner")
      allow(dummy.class).to receive(:base_class).and_return(dummy.class)

      Secretkeeper.reflect do |on|
        on.resource_owner do |params|
          dummy
        end
      end

      post :create_token

      expect(response).to have_http_status 201
      body = JSON.parse(response.body)
      expect(body.size).to eq 4
      token = Secretkeeper::AccessToken.first
      expect(body["access_token"]).to eq token.token
      expect(body["expires_in"]).to eq 6.hours.to_i
      expect(body["refresh_token"]).to eq token.refresh_token
      expect(body["created_at"]).to eq token.created_at.to_i
    end
  end

  context "POST refresh_token" do
    it "creates new access_token" do
      old_token = create(:access_token)
      post :refresh_token, params: { refresh_token: old_token.refresh_token }
      expect(Secretkeeper::AccessToken.count).to eq 2
    end

    it "returns valid JSON" do
      old_token = create(:access_token)
      post :refresh_token, params: { refresh_token: old_token.refresh_token }
      expect(response).to have_http_status 200

      body = JSON.parse(response.body)
      token = Secretkeeper::AccessToken.last
      expect(body.size).to eq 4
      expect(body["access_token"]).to eq token.token
      expect(body["expires_in"]).to eq 6.hours.to_i
      expect(body["refresh_token"]).to eq token.refresh_token
      expect(body["created_at"]).to eq token.created_at.to_i
    end

    it "returns 403 http status code" do
      token = create(:access_token)
      post :refresh_token, params: { refresh_token: token.refresh_token + "1" }
      expect(response).to have_http_status 403
      expect(response.body).to be_empty
    end
  end
end