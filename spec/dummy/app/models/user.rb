class User < ApplicationRecord
  def self.authenticate!(name, password)
    User.find_by(name: name, password: password)
  end
end
