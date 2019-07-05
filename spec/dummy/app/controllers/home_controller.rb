class HomeController < ActionController::API
  before_action :secretkeeper_authorize!, only: :protected_action

  def protected_action
    render json: {
      resource_owner: @resource_owner.name
    }
  end
end
