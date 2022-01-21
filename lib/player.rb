module Platformer
  class Player < Actor
    # ---=== UPDATE : ===---
    def update(args,room)
  
      # --- 1. Updating state :
      super(args)
  
      # --- 2. Collisions :
      collision_rects, bottom_tile  = surrounding_tiles(room)
      @dx, @dy, diagonal            = Collisions::resolve_collisions_with_rects [ @x, @y ],
                                                                                [ @animation.width, @animation.height],
                                                                                [ @dx, @dy ],
                                                                                collision_rects
  
      @dx, @dy = 0.0, -1.0 if diagonal && bottom_tile == :empty
  
      @x += @dx
      @y += @dy
    end
  end
end
