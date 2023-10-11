class Command::Take < Command
  def execute(client, arguments)
    if arguments.blank?
      client.send_line("Please specify what you'd like to take.")
      return
    end

    # take the first exact match (case-insensitive), or take a similar match (include?) if there's only one and it's
    # not a duplicate of the same item
    #
    # e.g. a room with Blue Torch and Red Torch will not pick up "torch", but two Blue Torches would pick up one
    #
    # "all" will take all items in the current room
    item_request = arguments.downcase
    possible_items = []

    if item_request == 'all'
      client.user.items << client.user.room.items
      client.user.save
      client.user.room.items.reload

      client.send_line('Took all items.')
      return
    end

    client.user.room.items.each do |i|
      name = i.name.downcase

      if name == item_request
        # TODO: could clean up the "take" response and saving, since it's duplicated below
        client.user.items << i
        client.user.save
        # TODO/KLUDGE: we have to call reload here, because for this client (or maybe the whole server?) this room's
        # items were modified in the DB, but not on the object itself. couldn't find a global setting for this with
        # respect to associations. QueryCache is a thing, but not for this (and that's disabled by default)
        client.user.room.items.reload

        client.send_line("Took #{i.name}")
        return
      elsif name.include?(item_request)
        possible_items << i
      end
    end

    if possible_items.blank?
      client.send_line("No \"#{arguments}\" here to take.")
    elsif possible_items.count > 1 && possible_items.map(&:name).uniq.count > 1
      client.send_line("Multiple \"#{arguments}\" here to take. Be more specific.")
    else
      client.user.items << possible_items.first
      client.user.save
      # TODO/KLUDGE: we have to call reload here, because for this client (or maybe the whole server?) this room's
      # items were modified in the DB, but not on the object itself. couldn't find a global setting for this with
      # respect to associations. QueryCache is a thing, but not for this (and that's disabled by default)
      client.user.room.items.reload

      client.send_line("Took #{possible_items.first.name}")
    end
  end

  private

  def setup_attributes
    @description = 'Pick up items from the current room'
  end
end
