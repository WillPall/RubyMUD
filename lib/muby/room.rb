class Muby::Room < ActiveRecord::Base
  has_many :users
  has_many :connections
  has_many :destinations, through: :connections

  def render
    output = map_string
    output += "\n" + Paint[self.title, :yellow] + "\n"
    output += self.description + "\n"

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

  def map_string(horizontal_radius = 6, vertical_radius = 3)
    # start with the top right room
    current_room = room_at_distance(vertical_radius, 'north').room_at_distance(horizontal_radius, 'west')
    output = ''

    (vertical_radius * 2 + 1).times do |i|
      (horizontal_radius * 2 + 1).times do |i|
        if current_room.id == self.id
          output += Paint['&', :white, :bright]
        else
          output += Muby::Room.map_representation(current_room)
        end

        current_room = current_room.room_at_distance(1, 'east')
      end

      output += "\n"
      current_room = current_room.room_at_distance(1, 'south').room_at_distance(horizontal_radius * 2 + 1, 'west')
    end

    output
  end
end
