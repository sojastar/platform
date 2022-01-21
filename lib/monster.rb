module Platformer
  class Monster < Actor
    # ---=== INITIALIZE : ===---
    def initialize(animation,fsm,start_x,start_y,health,path,speed) 
      super animation, fsm, start_x, start_y, health

      @path   = path
      @speed  = speed
    end

    # ---=== UPDATE : ===---
    def update(args,room)
  
      # --- 1. Updating state :
      super(args)
  
      # --- 2. Movement :
      @x += @dx
      @y += @dy
    end

    # ---=== SERIALIZATION : ===---
    def serialize
      { x: @x, y: @y, health: @health, path: @path, speed: @speed }
    end
  
    def inspect() serialize.to_s  end
    def to_s()    serialize.to_s  end 
  end
end
