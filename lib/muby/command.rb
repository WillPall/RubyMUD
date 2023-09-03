class Muby::Command
  attr_accessor :name
  attr_accessor :description

  def execute
    puts 'Command [' + name.to_s + '] executed'
  end
end
