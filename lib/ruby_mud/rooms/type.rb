# A collection of rooms
class Rooms::Type < ActiveRecord::Base
  has_many :rooms, class_name: 'Rooms::Room'
end
