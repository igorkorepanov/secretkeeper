# frozen_string_literal: true

module Secretkeeper
  class AuthController < ActionController::Metal
    include AbstractController::Rendering
    include ActionController::Head
    include ActionController::Renderers
    include ActionController::Rendering

    use_renderers :json

    def create_token
      resource_owner = Secretkeeper.reflection_resource_owner.call(params)

      return head 401 if resource_owner.nil?

      @access_token = Secretkeeper::AccessToken.create(owner: resource_owner)
      render json: success, status: 201
    end

    def refresh_token
      return head 403 unless old_token&.refreshable?

      old_token.revoke!
      @access_token = Secretkeeper::AccessToken.create(owner: old_token.owner)
      render json: success
    end

    private

    def success
      {
        access_token: @access_token.token,
        expires_in: @access_token.expires_in,
        refresh_token: @access_token.refresh_token,
        created_at: @access_token.created_at.to_i
      }
    end

    def old_token
      @old_token ||=
        Secretkeeper::AccessToken.find_by(refresh_token: params[:refresh_token])
    end
  end
end
