require "generator_spec"
require "generators/secretkeeper/install_generator"

describe Secretkeeper::InstallGenerator, type: :generator do
  destination File.expand_path("../../../dummy/tmp", __FILE__)

  before :all do
    prepare_destination

    FileUtils.mkdir(::File.expand_path("config", Pathname(destination_root)))
    FileUtils.copy_file(
      ::File.expand_path("../templates/routes.rb", __FILE__),
      ::File.expand_path("config/routes.rb",
      Pathname.new(destination_root))
    )
  end

  context "routes" do
    it "adds route" do
      run_generator ["--force"]
      assert_file "config/routes.rb", /secretkeeper/
    end
  end

  context "initializers" do
    it "creates an initializer file" do
      allow(Rails).to receive(:version).and_return "4.2.0"

      run_generator ["--force"]

      assert_file "config/initializers/secretkeeper.rb"
    end
  end

  context "migrations" do
    it "creates a migration with no version specifier" do
      allow(Rails).to receive(:version).and_return "4.2.0"

      run_generator ["--force"]

      assert_migration "db/migrate/create_secretkeeper_tables.rb" do |migration|
        assert migration.include?("ActiveRecord::Migration\n")
      end
    end

    it "creates a migration with a version specifier" do
      allow(Rails).to receive(:version).and_return "5.0.0"

      stub_const("Rails::VERSION::MAJOR", 5)
      stub_const("Rails::VERSION::MINOR", 0)

      run_generator ["--force"]

      assert_migration "db/migrate/create_secretkeeper_tables.rb" do |migration|
        assert migration.include?("ActiveRecord::Migration[5.0]\n")
      end
    end
  end
end
