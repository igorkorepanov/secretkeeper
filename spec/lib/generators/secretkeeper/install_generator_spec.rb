# frozen_string_literal: true

require 'spec_helper'
require 'generator_spec'
require 'generators/secretkeeper/install_generator'

describe Secretkeeper::InstallGenerator, type: :generator do
  destination File.expand_path(Rails.root.join('tmp'))

  before do
    prepare_destination

    FileUtils.mkdir(::File.expand_path('config', Pathname(destination_root)))
    FileUtils.copy_file(
      ::File.expand_path('../../../../support/routes.rb', __FILE__),
      ::File.expand_path('config/routes.rb', Pathname.new(destination_root))
    )
  end

  after { remove_test_files }

  describe 'routes' do
    it 'adds routes' do
      run_generator ['--force']
      assert_file 'config/routes.rb', /secretkeeper/
    end
  end

  describe 'initializers' do
    it 'creates an initializer file' do
      allow(Rails).to receive(:version).and_return '4.2.0'

      run_generator ['--force']

      assert_file 'config/initializers/secretkeeper.rb'
    end
  end

  describe 'migrations' do
    it 'creates a migration with no version specifier' do
      allow(Rails).to receive(:version).and_return '4.2.0'

      run_generator ['--force']

      assert_migration 'db/migrate/create_secretkeeper_tables.rb' do |migration|
        assert migration.include?("ActiveRecord::Migration\n")
      end
    end

    it 'creates a migration with a version specifier' do
      allow(Rails).to receive(:version).and_return '5.0.0'

      stub_const('Rails::VERSION::MAJOR', 5)
      stub_const('Rails::VERSION::MINOR', 0)

      run_generator ['--force']

      assert_migration 'db/migrate/create_secretkeeper_tables.rb' do |migration|
        assert migration.include?("ActiveRecord::Migration[5.0]\n")
      end
    end
  end

  def remove_test_files
    FileUtils.rm_rf Rails.root.join('tmp')
  end
end
