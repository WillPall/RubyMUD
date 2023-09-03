class Muby::MessageHelper
  class << self
    def info_message(message)
      "#{Paint['[info]', :cyan]} #{message}"
    end

    def user_message(user, message, user_color = :green)
      "#{Paint["#{user.name} says:", user_color]} #{message}"
    end

    def feedback_message(message)
      "#{Paint['you say:', :yellow]} #{message}"
    end
  end
end
