require "secretkeeper/rails/helpers"

module Secretkeeper
  class Engine < ::Rails::Engine
    initializer "secretkeeper.controller_helpers" do
      ActiveSupport.on_load(:action_controller) do
        include Secretkeeper::Rails::Helpers
      end
    end
  end
end
