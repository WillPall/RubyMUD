class Muby::Room::Connection < ActiveRecord::Base
  belongs_to :room
  belongs_to :destination, class_name: 'Muby::Room'
end
