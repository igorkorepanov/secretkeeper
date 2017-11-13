module Secretkeeper
  class AccessToken < ::ActiveRecord::Base
    self.table_name = "secretkeeper_access_tokens"
    belongs_to :owner, polymorphic: true

    def initialize(attributes = {})
      access_token, refresh_token, expires_in = nil
      loop do
        access_token = AccessToken.generate
        refresh_token = AccessToken.generate
        break unless AccessToken.exists?(token: access_token, refresh_token: refresh_token)
      end
      expires_in = Secretkeeper.configuration.access_token_expires_in
      super((attributes || {}).merge({
        token: access_token, refresh_token: refresh_token, expires_in: expires_in
      }))
    end

    def revoke!
      revoked_at.nil? && update_attribute(:revoked_at, DateTime.now)
    end

    def accessible?
      !revoked? && !expired?
    end

    def revoked?
      revoked_at.present?
    end

    def expired?
      created_at + expires_in.seconds <= DateTime.now
    end

    def refreshable?
      !revoked?
    end

    def self.generate
      SecureRandom.hex(32)
    end
  end
end
