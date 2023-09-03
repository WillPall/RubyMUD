# This is the base class for all commands. Each command should call `super`
# during initialization to set up the defaults. That should probably be moved
# out into a factory (or look into other ways to make it automatic)
class Muby::Command
  attr_accessor :name
  attr_accessor :description
  # TODO: originally I wrote this as `is_visible?` to denote that it wasn't supposed to show up in any lists
  # but that it should still be a commamnd that could be run. specifically for the `direction` command for
  # moving between areas. let's figure out how better to do this 
  attr_accessor :is_special_type
  # whether the user needs to type the full command name to execute
  attr_accessor :requires_full_name

  def initialize
    self.is_special_type = false
    self.requires_full_name = false
  end

  def execute
    puts 'Command [' + name.to_s + '] executed'
  end

  def is_special_type!
    self.is_special_type = true
  end

  def requires_full_name!
    self.requires_full_name = true
  end

  def can_be_abbreviated?
    !self.requires_full_name
  end
end
