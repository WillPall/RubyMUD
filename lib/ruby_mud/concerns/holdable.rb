module Holdable
  extend ActiveSupport::Concern

  included do
    has_many :item_instances, as: :holdable, class_name: 'Items::ItemInstance'
  end
end
