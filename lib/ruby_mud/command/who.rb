class Command::Who < Command
  def execute(client, arguments)
    other_online_users = User.where(online: true).where.not(id: client.user.id).order(:name)

    # TODO: center this once we know the client terminal size?
    client.send_line(Paint['=== Online Users ===', :bright, :green])

    if other_online_users.present?
      other_online_users.each do |user|
        client.send_line(user.name)
      end
    else
      client.send_line("There's no one else here")
    end
  end

  private

  def setup_attributes
    @description = 'Lists all players currently online'
  end
end
