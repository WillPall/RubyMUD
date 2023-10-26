class Items::ItemInstance < ActiveRecord::Base
  belongs_to :holdable, polymorphic: true
  belongs_to :item
end
