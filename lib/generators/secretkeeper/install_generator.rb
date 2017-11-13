require "rails/generators/active_record"

class Secretkeeper::InstallGenerator < ::Rails::Generators::Base
  include Rails::Generators::Migration

  source_root File.expand_path("../templates", __FILE__)

  def install
    copy_file "initializer.rb", "config/initializers/secretkeeper.rb"
    migration_template(
      "migration.rb",
      "db/migrate/create_secretkeeper_tables.rb",
      migration_version: migration_version
    )
    route "secretkeeper"
  end

  def self.next_migration_number(dirname)
    next_migration_number = current_migration_number(dirname) + 1
    ActiveRecord::Migration.next_migration_number(next_migration_number)
  end

  def migration_version
    if Rails.version >= "5.0.0"
      "[#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}]"
    end
  end
end
