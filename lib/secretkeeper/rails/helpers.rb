# frozen_string_literal: true

module Secretkeeper
  module Rails
    module Helpers
      extend ActiveSupport::Concern

      def secretkeeper_authorize!
        return secretkeeper_render_error unless secretkeeper_token_acceptable?

        @resource_owner = secretkeeper_access_token.owner
      end

      private

      def secretkeeper_token_acceptable?
        secretkeeper_auth_header_valid? &&
          secretkeeper_access_token.owner.present?
      end

      def secretkeeper_auth_header_valid?
        request.headers['Authorization']&.start_with?('Bearer ') &&
          secretkeeper_access_token&.accessible?
      end

      def secretkeeper_access_token
        @secretkeeper_access_token ||= Secretkeeper::AccessToken.find_by(
          token: request.headers['Authorization'][7..-1]
        )
      end

      def secretkeeper_render_error
        head 401
      end
    end
  end
end
