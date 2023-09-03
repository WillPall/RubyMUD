class Muby::Room < ActiveRecord::Base
  has_many :users
  has_many :connections
  has_many :destinations, through: :connections
end
