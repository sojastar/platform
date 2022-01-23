module Platformer
  class Item < Actor
    attr_reader :type,
                :single

    # ---=== INITIALIZE : ===---
    def initialize(type,single,animation,fsm,size,position) 
      super animation, fsm, size, position, -1

      @type   = type
      @single = single

      @machine.start
    end

    def reset
      enable
    end
  end
end
