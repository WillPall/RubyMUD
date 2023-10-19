class Room < ActiveRecord::Base
  include Holdable, Updateable

  has_many :users
  has_many :connections
  has_many :destinations, through: :connections
  belongs_to :area
  belongs_to :room_type

  def render
    output = map_view
    output += "\n" + Paint[self.title, :yellow] + "\n"
    output += self.description + "\n"

    if items.present?
      output += 'Items: '

      items.each do |item|
        output += "\t#{item.name}\n"
      end
    end

    if self.connections.present?
      output += 'Exits: '

      self.connections.each do |connection|
        output += "#{Paint[connection.name, :green]} "
      end
    end

    output
  end

  def title
    self[:title] || self.room_type.default_title
  end

  def description
    self[:description] || self.room_type.default_description
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
