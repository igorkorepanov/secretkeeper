# frozen_string_literal: true

module Secretkeeper
  class << self
    attr_reader :reflection_resource_owner

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end

    def reflect(&block)
      class_eval(&block)
    end

    def resource_owner(&block)
      @reflection_resource_owner = block
    end
  end

  class Configuration
    attr_accessor :access_token_expires_in
  end
end
