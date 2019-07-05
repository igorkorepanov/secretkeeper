# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'

require 'dummy/config/environment'
abort('The Rails environment is running in production mode!') if Rails.env.production?
require 'rspec/rails'
require 'rspec/json_expectations'
require 'factory_bot'

ActiveRecord::Migration.verbose = false
load Rails.root + 'db/schema.rb'

FactoryBot.definition_file_paths << File.join(File.dirname(__FILE__), 'factories')

FactoryBot.factories.clear
FactoryBot.find_definitions

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  config.infer_spec_type_from_file_location!

  config.infer_base_class_for_anonymous_controllers = false

  config.use_transactional_fixtures = true

  config.order = 'random'
end
