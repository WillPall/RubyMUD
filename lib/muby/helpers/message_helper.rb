class Muby::MessageHelper
  class << self
    def info_message(message)
      "#{Paint['[info]', :cyan]} #{message}"
    end
  end
end
