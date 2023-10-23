class Room < ActiveRecord::Base
  include Holdable, StateUpdateable

  has_many :users
  has_many :non_player_characters
  has_many :connections
  has_many :destinations, through: :connections
  belongs_to :area
  belongs_to :room_type

  after_create :create_connections, :adjust_coordinates

  def render
    render_for(nil)
  end

  def render_for(user)
    output = map_view
    output += "\n" + Paint[self.display_title, :yellow] + "\n"
    output += self.display_description + "\n"

    if items.present?
      output += 'Items: '

      items.each do |item|
        output += "\t#{item.name}\n"
      end
    end

    if connections.present?
      output += 'Exits: ' + connections.map { |c| "#{Paint[c.name, :green]}" }.join(', ') + "\n"
    end

    non_player_characters.each do |npc|
      output += "#{npc.name} is here.\n"
    end

    users_to_show = online_users
    if user.present?
      users_to_show = online_users.where.not(id: user.id)
    end

    users_to_show.each do |u|
      output += "(Player) #{u.name} is here.\n"
    end

    output
  end

  def display_title
    self.title || self.room_type.default_title
  end

  def display_description
    self.description || self.room_type.default_description
  end

  def online_users
    users.where(online: true)
  end

  def map_representation
    Paint[self.room_type.map_character, self.room_type.map_color.to_sym, (self.room_type.map_is_bright? ? :bright : nil)]
  end

  protected

  def room_at_distance(distance, direction)
    final_room = self
    distance.times do |i|
      connection = final_room.connections.where(name: direction).first

      if connection.present?
        final_room = final_room.connections.where(name: direction).first.destination
      else
        return nil
      end
    end

    final_room
  end

  private

  def create_connections
    north = Room.where(area: self.area, x: self.x, y: self.y - 1).first
    south = Room.where(area: self.area, x: self.x, y: self.y + 1).first
    east = Room.where(area: self.area, x: self.x + 1, y: self.y).first
    west = Room.where(area: self.area, x: self.x - 1, y: self.y).first

    if north.present?
      self.connections << Room::Connection.create(room: self, destination: north, name: 'north')
      north.connections << Room::Connection.create(room: north, destination: self, name: 'south')
    end
    if south.present?
      self.connections << Room::Connection.create(room: self, destination: south, name: 'south')
      south.connections << Room::Connection.create(room: south, destination: self, name: 'north')
    end
    if east.present?
      self.connections << Room::Connection.create(room: self, destination: east, name: 'east')
      east.connections << Room::Connection.create(room: east, destination: self, name: 'west')
    end
    if west.present?
      self.connections << Room::Connection.create(room: self, destination: west, name: 'west')
      west.connections << Room::Connection.create(room: west, destination: self, name: 'east')
    end
  end

  def adjust_coordinates
    x_difference = 0
    y_difference = 0

    if self.x < 0
      x_difference = -self.x
    end
    if self.y < 0
      y_difference = -self.y
    end

    if x_difference > 0 || y_difference > 0
      Room.where(area: self.area).each do |room|
        room.x += x_difference
        room.y += y_difference
        room.save
      end
    end
  end

  def map_view(horizontal_radius = 6, vertical_radius = 3)
    map = self.area.map(horizontal_radius: horizontal_radius, vertical_radius: vertical_radius, starting_room: self)
    output = ''

    map.each_with_index do |row, y|
      if row.blank?
        next
      end

      row.each_with_index do |room, x|
        if room.blank?
          output += ' '
          next
        end

        if room.id == self.id
          output += Paint['&', :white, :bright]
        else
          output += room.map_representation
        end
      end

      output += "\n"
    end

    output
  end
end
