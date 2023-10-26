class Commands::Inventory < Commands::Command
  def execute(client, arguments)
    client.send_line(Paint['Equipped', :green])
    client.send_line("\tNone")
    client.send_line(Paint['Backpack', :green])

    if client.user.item_instances.blank?
      client.send_line("\tNone")
    end

    client.user.item_instances.sort_by { |i| i.item.name }.each do |instance|
      client.send_line("\t#{instance.item.name}")
    end
  end

  private

  def setup_attributes
    @description = 'Displays equipment and held items'
  end
end
