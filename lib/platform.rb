module Platformer
  class Platform < Actor
    # ---=== INITIALIZATION : ===---
    def initialize(animation,fsm,size,position,path)
      super animation, fsm, size, position, -1

      @path = path
       
      reset
    end


    # ---=== UPDATE : ===---
    def update(args,room)
  
      # --- 1. Updating state :
      super(args)
  
      # --- 2. Movement :
      @x += @dx
      @y += @dy
    end

    def reset
      @path.reset
      @x = @path.current_step[:start][0] 
      @y = @path.current_step[:start][1] 

      @machine.start

      enable
    end


    # ---=== SERIALIZATION : ===---
    def serialize
      { x: @x, y: @y, health: @health, path: @path, speed: @speed }
    end
  
    def inspect() serialize.to_s  end
    def to_s()    serialize.to_s  end 
  end
end
