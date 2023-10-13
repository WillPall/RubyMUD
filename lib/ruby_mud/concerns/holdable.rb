module Holdable
  extend ActiveSupport::Concern

  included do
    has_many :items, as: :holdable, class_name: 'Items::Item'
  end
end
