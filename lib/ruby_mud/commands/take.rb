class Commands::Take < Commands::Command
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

    if item_request == 'all'
      client.user.item_instances << client.user.room.item_instances
      client.user.save
      client.user.room.item_instances.reload

      client.send_line('Took all items.')
      return
    end

    possible_item_instances = Items.match(item_request, client.user.room.item_instances)

    if possible_item_instances.blank?
      client.send_line("No \"#{arguments}\" here to take.")
    elsif possible_item_instances.count > 1 && possible_item_instances.map { |i| i.item.name }.uniq.count > 1
      client.send_line("Multiple \"#{arguments}\" here to take. Be more specific.")
    else
      client.user.item_instances << possible_item_instances.first
      client.user.save
      # TODO/KLUDGE: we have to call reload here, because for this client (or maybe the whole server?) this room's
      # items were modified in the DB, but not on the object itself. couldn't find a global setting for this with
      # respect to associations. QueryCache is a thing, but not for this (and that's disabled by default)
      client.user.room.item_instances.reload

      client.send_line("Took #{possible_item_instances.first.item.name}")
    end
  end

  private

  def setup_attributes
    @description = 'Pick up items from the current room'
  end
end
