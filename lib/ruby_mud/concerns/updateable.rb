module StateUpdateable
  extend ActiveSupport::Concern

  included do
    after_initialize :register_updateable

    def state_update(delta)
      # should be overwritten by the updateable class
    end
  end

  private
  
  def register_updateable
    RubyMUD.game.register_updateable(self)
  end
end
