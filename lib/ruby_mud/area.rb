class Area < ActiveRecord::Base
  has_many :rooms
  belongs_to :starting_room, class_name: 'Room'
end
