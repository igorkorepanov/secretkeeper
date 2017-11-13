module Secretkeeper
  class AuthController < ActionController::Metal
    include AbstractController::Rendering
    include ActionController::Rendering
    include ActionController::Renderers
    include ActionController::Head

    use_renderers :json

    def create_token
      resource_owner = Secretkeeper.reflection_resource_owner.call(params)
      if resource_owner.present?
        access_token = Secretkeeper::AccessToken.create(owner: resource_owner)
        render json: {
          access_token: access_token.token,
          expires_in: access_token.expires_in,
          refresh_token: access_token.refresh_token,
          created_at: access_token.created_at.to_i
        }, status: 201
      else
        head 401
      end
    end

    def refresh_token
      token = Secretkeeper::AccessToken.find_by(refresh_token: params[:refresh_token])
      if token.present? && token.refreshable?
        token.revoke!
        new_token = Secretkeeper::AccessToken.create(owner: token.owner)
        render json: {
          access_token: new_token.token,
          expires_in: new_token.expires_in,
          refresh_token: new_token.refresh_token,
          created_at: DateTime.now.to_i
        }
      else
        head 403
      end
    end
  end
end
