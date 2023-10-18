class Room < ActiveRecord::Base
  include Holdable, Updateable

  has_many :users
  has_many :connections
  has_many :destinations, through: :connections
  belongs_to :area

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
    self[:title] || DEFAULT_TITLES[self.room_type.to_sym]
  end

  def description
    self[:description] || DEFAULT_DESCRIPTIONS[self.room_type.to_sym]
  end

  def online_users
    users.where(online: true)
  end

  def self.map_representation(room = nil)
    if room.present?
      Paint['#', COLOR_MAPPING[room.room_type.to_sym][0], COLOR_MAPPING[room.room_type.to_sym][1]]
    else
      print Paint['*', :red, :bright]
    end
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

  DEFAULT_TITLES = {
    water: 'Deep Water',
    grass: 'Grassy Plain',
    sand: 'Sandy Beach',
    forest: 'Dense Forest',
    road: 'Road'
  }

  DEFAULT_DESCRIPTIONS = {
    water: "You're in the middle of a deep pool of water",
    grass: 'Waves of grass and wheat surround you',
    sand: 'The sand crunches between your toes',
    forest: 'The trees whisper in the wind around you',
    road: 'This road leads to Rome'
  }

  COLOR_MAPPING = {
    water: [:blue],
    grass: [:green, :bright],
    sand: [:yellow, :bright],
    forest: [:green],
    road: [:yellow]
  }

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
          output += Room.map_representation(room)
        end
      end

      output += "\n"
    end

    output
  end
end
