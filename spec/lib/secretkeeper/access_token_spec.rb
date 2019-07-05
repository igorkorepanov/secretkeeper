# frozen_string_literal: true

require 'spec_helper'

describe Secretkeeper::AccessToken, type: :model do
  include ActiveSupport::Testing::TimeHelpers

  let(:token_expire_time) { 1.minute }
  let(:token) { create(:access_token) }

  before do
    allow(Secretkeeper.configuration).to receive(:access_token_expires_in)
      .and_return(token_expire_time)
  end

  describe '#initialize' do
    let(:token) { described_class.create(token: 1, refresh_token: 2) }

    it 'creates model instance' do
      aggregate_failures do
        expect(token.token).to be_a String
        expect(token.refresh_token).to be_a String
        expect(token.token.length).to eq 64
        expect(token.refresh_token.length).to eq 64
      end
    end
  end

  describe '#revoke!' do
    it 'revokes refresh_token' do
      freeze_time do
        aggregate_failures do
          expect(token.revoke!).to be_truthy
          expect(token.revoked_at).to eq Time.zone.now
        end
      end
    end

    it 'cannot be revoked twice' do
      aggregate_failures do
        expect(token.revoke!).to be_truthy
        expect(token.revoke!).to be_falsey
      end
    end
  end

  describe '#accessible?' do
    it { expect(token).to be_accessible }

    it 'creates expired access token' do
      token = create(
        :access_token,
        created_at: Time.zone.now - token_expire_time,
        expires_in: token_expire_time
      )

      expect(token).not_to be_accessible
    end
  end

  describe '#revoked?' do
    it { expect(token).not_to be_revoked }

    it 'returns true' do
      token = create(:access_token, revoked_at: 1.year.ago)
      expect(token).to be_revoked
    end
  end

  describe '#expired?' do
    it { expect(token).not_to be_expired }

    it 'returns true' do
      token = create(:access_token, created_at: 1.year.ago)
      expect(token).to be_expired
    end
  end

  describe '#refreshable?' do
    it { expect(token).to be_refreshable }

    it 'returns false when the token is revoked' do
      token.revoke!
      expect(token).not_to be_refreshable
    end
  end

  describe '.generate' do
    it 'generates a hex string' do
      str = described_class.generate
      expect(str).to be_a String
      expect(str.length).to eq 64
    end
  end
end
