class User < ActiveRecord::Base
    has_many :tasks

    validates :name, presence: true, uniqueness: true
    has_secure_password
end
