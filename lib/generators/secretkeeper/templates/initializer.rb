Secretkeeper.configure do |config|
  config.access_token_expires_in = 12.hours
end

Secretkeeper.reflect do |on|
  on.resource_owner do |params|
    User.authenticate!(params[:name], params[:password])
  end
end
