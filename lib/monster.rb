module Platformer
  class Monster < Actor
    # ---=== INITIALIZE : ===---
    def initialize(animation,fsm,start_x,start_y,health,path,speed) 
      super animation, fsm, start_x, start_y, health

      @path = path
    end

    # ---=== UPDATE : ===---
    def update(args,room)
  
      # --- 1. Updating state :
      super(args)
  
      # --- 2. Collisions :
      @x += @dx
      @y += @dy
    end
  end
end
