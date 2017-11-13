module Secretkeeper
  class << self
    attr_accessor :configuration
    attr_accessor :reflection_resource_owner
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end

  def self.reflect(&block)
    class_eval(&block)
  end

  def self.resource_owner(&block)
    @reflection_resource_owner = block
  end

  class Configuration
    attr_accessor :access_token_expires_in

    def initialize
      @access_token_expires_in = 1.hour
    end
  end
end
