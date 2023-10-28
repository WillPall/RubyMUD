class Rooms::Connection < ActiveRecord::Base
  belongs_to :room, class_name: 'Rooms::Room'
  belongs_to :destination, class_name: 'Rooms::Room'
end
