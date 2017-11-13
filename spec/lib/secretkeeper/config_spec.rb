require "spec_helper"

RSpec.describe Secretkeeper::Configuration do
  it "creates access_token with valid expiration date" do
    Secretkeeper.configure do |config|
      config.access_token_expires_in = 1.hour
    end

    token = build(:access_token)
    expect(token.expires_in).to eq 3600
  end

  it "returns resource owner" do
    dummy = mock_model("ResourceOwner")
    Secretkeeper.reflect do |on|
      on.resource_owner do |params|
        dummy
      end
    end
    resource_owner = Secretkeeper.reflection_resource_owner.call

    expect(resource_owner).to eq dummy
  end
end
