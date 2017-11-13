module Secretkeeper
  module Rails
    module Helpers
      extend ActiveSupport::Concern

      def secretkeeper_authorize!
        header = request.headers["Authorization"]
        if header && header.start_with?("Bearer ")
          token = Secretkeeper::AccessToken.find_by(token: header[7..-1])
          if token.present? && token.accessible?
            @resource_owner = token.owner
            return true 
          end
        end
        head 401
      end
    end
  end
end
