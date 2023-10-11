class Command::Inventory < Command
  def execute(client, arguments)
    client.send_line(Paint['Equipped', :green])
    client.send_line("\tNone")
    client.send_line(Paint['Backpack', :green])

    if client.user.items.blank?
      client.send_line("\tNone")
    end

    client.user.items.sort_by(&:name).each do |i|
      client.send_line("\t#{i.name}")
    end
  end

  private

  def setup_attributes
    @description = 'Displays equipment and held items'
  end
end
