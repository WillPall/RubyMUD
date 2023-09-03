class Muby::User < ActiveRecord::Base
  belongs_to :room

  attr_accessor :connection

  def can_move?(destination)
    self.room.connections.where(name: destination).present?
  end

  def move_to(destination)
    destination_room = room.connections.where(name: destination).first.destination
    self.room = destination_room
    self.save

    self.connection.send_line(destination_room.title)
    self.connection.send_line(destination_room.description)
  end
end
