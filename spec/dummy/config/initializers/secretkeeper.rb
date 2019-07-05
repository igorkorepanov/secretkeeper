Secretkeeper.configure do |config|
  config.access_token_expires_in = 12.hours
end

Secretkeeper.reflect do |on|
  on.resource_owner do |params|
    case params[:resource_owner]
    when 'Admin'
      Admin.authenticate!(params[:name], params[:password])
    when 'User'
      User.authenticate!(params[:name], params[:password])
    else
    end
  end
end
