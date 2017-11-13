Rails.application.routes.draw do
  secretkeeper

  get "/protected_action" => "home#protected_action"
end
