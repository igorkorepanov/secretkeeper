require "spec_helper"

RSpec.describe Secretkeeper::AccessToken, type: :model do
  before do
    allow(Secretkeeper.configuration).to receive(:access_token_expires_in).and_return(1.minute)
  end

  context "initialize" do
    it "initialize a model instance" do
      token = build(:access_token)
      expect(token.token).to be_a String
      expect(token.refresh_token).to be_a String
      expect(token.token.length).to eq 64
      expect(token.refresh_token.length).to eq 64
      expect(token.revoked_at).to eq nil
    end

    it "creates a model instance" do
      token = create(:access_token)
      expect(token.token).to be_a String
      expect(token.refresh_token).to be_a String
      expect(token.token.length).to eq 64
      expect(token.refresh_token.length).to eq 64
    end

    it "overrides initial attributes" do
      token = Secretkeeper::AccessToken.create({token: 1, refresh_token: 2})
      expect(token.token).to be_a String
      expect(token.refresh_token).to be_a String
      expect(token.token.length).to eq 64
      expect(token.refresh_token.length).to eq 64
    end
  end

  context "revoke!" do
    it "revokes refresh_token" do
      token = create(:access_token)
      expect(token.revoke!).to be true
      expect(token.revoked_at).to be <= DateTime.now
    end

    it "can't be revoked twice" do
      token = create(:access_token)
      expect(token.revoke!).to be true
      expect(token.revoke!).to be false
    end
  end

  context "accessible?" do
    it "should be accessible" do
      token = create(:access_token)
      expect(token.accessible?).to be true
    end

    it "creates expired access token" do
      token = create(:access_token, { expires_in: 100.years.ago })
      expect(token.accessible?).to be false
    end
  end

  context "revoked?" do
    it "returns false" do
      token = create(:access_token)
      expect(token.revoked?).to be false
    end

    it "returns true" do
      token = create(:access_token, { revoked_at: 1.year.ago })
      expect(token.revoked?).to be true
    end
  end

  context "expired?" do
    it "returns false" do
      token = create(:access_token)
      expect(token.expired?).to be false
    end

    it "returns true" do
      token = create(:access_token, { created_at: 1.year.ago })
      expect(token.expired?).to be true
    end
  end

  context "refreshable?" do
    it "returns true" do
      token = create(:access_token)
      expect(token.refreshable?).to be true
    end

    it "returns false (revoked token)" do
      token = create(:access_token)
      token.revoke!
      expect(token.refreshable?).to be false
    end
  end

  context "self.generate" do
    it "generates a hex string" do
      str = Secretkeeper::AccessToken.generate
      expect(str).to be_a String
      expect(str.length).to eq 64
    end
  end
end