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
end
