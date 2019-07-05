# frozen_string_literal: true

module Secretkeeper
  class AccessToken < ::ActiveRecord::Base
    self.table_name = 'secretkeeper_access_tokens'

    belongs_to :owner, polymorphic: true

    def initialize(attributes = {})
      loop do
        @access_token = AccessToken.generate
        @r_token = AccessToken.generate
        break unless token_exists?
      end
      @token_expires_in = Secretkeeper.configuration.access_token_expires_in
      super((attributes || {}).merge(token_params))
    end

    def revoke!
      revoked_at.nil? && update(revoked_at: Time.zone.now)
    end

    def accessible?
      !revoked? && !expired?
    end

    def revoked?
      revoked_at.present?
    end

    def expired?
      created_at + expires_in.seconds <= Time.zone.now
    end

    def refreshable?
      !revoked?
    end

    def self.generate
      SecureRandom.hex(32)
    end

    private

    attr_reader :access_token, :r_token, :token_expires_in

    def token_exists?
      AccessToken.exists?(token: access_token, refresh_token: r_token)
    end

    def token_params
      {
        token: access_token,
        refresh_token: r_token,
        expires_in: token_expires_in
      }
    end
  end
end
