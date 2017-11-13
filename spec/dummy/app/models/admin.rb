class Admin < ApplicationRecord
  def self.authenticate!(name, password)
    Admin.find_by(name: name, password: password)
  end
end
