class Muby::Command::Exit < Muby::Command
  def initialize
    super

    self.name = :exit
    self.description = 'Save and leave the server'
    self.aliases << :quit
    self.requires_full_name = true
  end

  def execute(client, arguments)
    # TODO: complete save of character
    client.user.save
    client.close_connection
    # binding.pry
  end
end

Muby::CommandHandler.register_command(Muby::Command::Exit.new)
