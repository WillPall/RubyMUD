class NonPlayerCharacter < ActiveRecord::Base
  include Holdable, StateUpdateable

  belongs_to :room
end
