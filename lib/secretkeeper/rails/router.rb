# frozen_string_literal: true

module ActionDispatch
  module Routing
    class Mapper
      def secretkeeper
        resources :auth, module: 'secretkeeper', only: [] do
          collection do
            post :create_token
            post :refresh_token
          end
        end
      end
    end
  end
end
