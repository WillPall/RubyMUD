class Command::Quit < Command
  def execute(client, arguments)
    client.user.save
    client.close_connection
  end

  private

  def setup_attributes
    @description = 'Save and leave the server'
    @requires_full_name = true
  end
end
