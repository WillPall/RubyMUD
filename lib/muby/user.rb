class Muby::User < ActiveRecord::Base
  # TODO: Make this a before_create, and make sure existing users have an
  # actual set of stats
  after_initialize :initialize_base_stats
  belongs_to :room

  attr_accessor :connection

  def can_move?(destination)
    self.room.connections.where(name: destination).present?
  end

  def move_to(destination)
    # tell everyone we're leaving
    self.connection.send_to_users("#{Paint[self.name, :green]} went #{Paint[destination, :green]}", room_users)

    # get the room associated from the destination they picked, then set that as their room
    destination_room = room.connections.where(name: destination).first.destination
    self.room = destination_room
    self.save

    self.connection.send_line(destination_room.render)
    self.connection.send_line(self.prompt)

    # tell everyone we've arrived
    self.connection.send_to_users("#{Paint[self.name, :green]} entered the area", room_users)
  end

  def room_users
    self.room.users.reject { |u| u == self }
  end

  def prompt
    health = Paint["H:#{percent(self.current_health, self.max_health)}%", :green]
    mana = Paint["M:#{percent(self.current_mana, self.max_mana)}%", :blue]

    "#{Paint['[', :gray]}#{health} #{Paint['|', :white, :bright]} #{mana}#{Paint[']', :gray]}"
  end

  private

  def percent(current, total)
    ((current / total) * 100).floor
  end

  def initialize_base_stats
    self.max_health = 10
    self.max_mana = 10

    self.current_health = 10
    self.current_mana = 10
  end
end
