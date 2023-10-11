class Items::Item < ActiveRecord::Base
  belongs_to :holdable, polymorphic: true
end
