class Items::Item < ActiveRecord::Base
  has_many :item_instances

  def create_instance
    Items::ItemInstance.create(
      item: self
    )
    self.item_instances.reload
  end
end
