module Items
  def self.table_name_prefix
    'items_'
  end

  def self.match(request, item_instances)
    possible_item_instances = []

    item_instances.each do |i|
      name = i.item.name.downcase

      # if it's exact, return that. otherwise add to the list if there are any that match
      if name == request
        return [i]
      elsif name.include?(request)
        possible_item_instances << i
      end
    end

    possible_item_instances
  end
end
