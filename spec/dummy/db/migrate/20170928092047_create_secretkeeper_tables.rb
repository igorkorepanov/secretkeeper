class CreateSecretkeeperTables < ActiveRecord::Migration[5.1]
  def change
    create_table :secretkeeper_access_tokens do |t|
      t.references :owner, polymorphic: true, index: true
      t.string     :token, null: false, index: true, unique: true
      t.string     :refresh_token, null: false, index: true, unique: true
      t.integer    :expires_in
      t.datetime   :revoked_at
      t.timestamps null: false
    end
  end
end
