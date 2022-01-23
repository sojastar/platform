module Platformer
  class Monster < Actor
    # ---=== INITIALIZE : ===---
    def initialize(animation,fsm,size,start_position,health,path,speed) 
      super animation, fsm, size, start_position, health

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
      @path_index = -1  # UUUUGH!!! So ugly!!! Have to do this because  ...
                        # ... the fsm initial state will immediately    ...
                        # ... increment the index in its setup block.
      @x, @y      = @path[0][0], @path[0][1]

      @machine.start

      enable
    end

    # ---=== PATH : ===---
    def go_to_next_path_step
      @path_index = ( @path_index + 1 ) % @path.length
    end

    def next_path_point
      @path[ ( @path_index + 1 ) % @path.length ]
    end


    # ---=== SERIALIZATION : ===---
    def serialize
      { x: @x, y: @y, health: @health, path: @path, speed: @speed }
    end
  
    def inspect() serialize.to_s  end
    def to_s()    serialize.to_s  end 
  end
end
