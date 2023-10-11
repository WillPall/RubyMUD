class Command::Drop < Command
  def execute(client, arguments)
    if arguments.blank?
      client.send_line("Please specify what you'd like to drop.")
      return
    end

    # drop the first exact match (case-insensitive), or drop a similar match (include?) if there's only one and it's
    # not a duplicate of the same item
    #
    # e.g. user with Blue Torch and Red Torch will not drop "torch", but two Blue Torches would drop one
    #
    # "all" will drop all items in the inventory
    item_request = arguments.downcase
    possible_items = []

    if item_request == 'all'
      client.user.room.items << client.user.items
      client.user.room.save
      client.user.items.reload

      client.send_line('Dropped all items.')
      return
    end

    client.user.items.each do |i|
      name = i.name.downcase

      if name == item_request
        # TODO: could clean up the "take" response and saving, since it's duplicated below
        client.user.room.items << i
        client.user.room.save
        # TODO/KLUDGE: we have to call reload here, because for this client (or maybe the whole server?) this room's
        # items were modified in the DB, but not on the object itself. couldn't find a global setting for this with
        # respect to associations. QueryCache is a thing, but not for this (and that's disabled by default)
        client.user.items.reload

        client.send_line("Dropped #{i.name}")
        return
      elsif name.include?(item_request)
        possible_items << i
      end
    end

    if possible_items.blank?
      client.send_line("No \"#{arguments}\" in your inventory.")
    elsif possible_items.count > 1 && possible_items.map(&:name).uniq.count > 1
      client.send_line("Multiple \"#{arguments}\" in your inventory. Be more specific.")
    else
      client.user.room.items << possible_items.first
      client.user.room.save
      # TODO/KLUDGE: we have to call reload here, because for this client (or maybe the whole server?) this room's
      # items were modified in the DB, but not on the object itself. couldn't find a global setting for this with
      # respect to associations. QueryCache is a thing, but not for this (and that's disabled by default)
      client.user.items.reload

      client.send_line("Dropped #{possible_items.first.name}")
    end
  end

  private

  def setup_attributes
    @description = 'Drop items from your inventory into the current room'
  end
end
