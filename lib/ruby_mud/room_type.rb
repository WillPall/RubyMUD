# A collection of rooms
class RoomType < ActiveRecord::Base
  has_many :rooms
end
