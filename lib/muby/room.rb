class Muby::Room < ActiveRecord::Base
  has_many :users
  has_many :connections
  has_many :destinations, through: :connections

  def render
    output = "\n" + Paint[self.title, :yellow] + "\n"
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
end
