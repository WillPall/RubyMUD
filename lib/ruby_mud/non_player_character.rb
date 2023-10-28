class NonPlayerCharacter < ActiveRecord::Base
  include Holdable, StateUpdateable

  belongs_to :room, class_name: 'Rooms::Room'
end
