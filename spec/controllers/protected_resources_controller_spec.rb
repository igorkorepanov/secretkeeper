require "spec_helper"

RSpec.describe "ProtectedControllerController", type: :controller do
  controller do
    before_action :secretkeeper_authorize!

    def index
      head 200
    end
  end

  context "empty headers" do
    it "does not allows into index action" do
      get :index
      expect(response).to have_http_status 401
    end
  end

  context "invalid access_token" do
    it "does not allows into index action" do
      request.headers.merge!({ authorization: "Bearer 123" })
      get :index
      expect(response).to have_http_status 401
    end
  end

  it "should respond_to secretkeeper_authorize!" do
    expect(controller).to respond_to(:secretkeeper_authorize!)
  end

  it "allows into index action" do
    token = double(Secretkeeper::AccessToken, {
      token: "abc", refresh_token: "abc", expires_in: 43200, revoked_at: nil
    })
    expect(Secretkeeper::AccessToken).to receive(:find_by).with({token: "abc"})
      .and_return(token)
    expect(token).to receive(:accessible?).and_return(true)
    expect(token).to receive(:owner).and_return("dummy")

    request.headers.merge!({ authorization: "Bearer #{token.token}" })
    get :index

    expect(response).to have_http_status 200
  end

  it "sets @resource_owner" do
    token = "token"
    expect(Secretkeeper::AccessToken).to receive(:find_by).with({token: "123"})
      .and_return(token)
    expect(token).to receive(:accessible?).and_return(true)
    expect(token).to receive(:owner).and_return("dummy")

    request.headers.merge!({ authorization: "Bearer 123" })
    get :index

    expect(controller.instance_variable_get(:@resource_owner)).to eq "dummy"
    # expect(assigns(:resource_owner)).to eq "dummy"
  end
end
