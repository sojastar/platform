module Platformer
  class Player < Actor
    attr_reader :death_tick

    # ---=== INITIALISATION : ===---
    def initialize(animation,fsm,size,start_x,start_y,health)
      super animation, fsm, size, start_x, start_y, health

      @actor_collisions = []
      @item_collisions  = []

      @death_tick       = 0

      @machine.start
    end


    # ---=== UPDATE : ===---
    def update(args,room)

      # --- 1. Updating state :
      super(args)
  
      # --- 2. Collisions :

      # - 2.1. With the tiles :
      collision_rects, bottom_tile  = surrounding_tiles(room)
      @dx, @dy, diagonal            = Collisions::resolve_collisions_with_rects [ @x, @y ],
                                                                                [ @animation.width, @animation.height],
                                                                                [ @dx, @dy ],
                                                                                collision_rects
  
      @dx, @dy = 0.0, -1.0 if diagonal && bottom_tile == :empty

      # - 2.2 With other actors :
      @actor_collisions = []
      if current_state != :death then
        room.actors.each do |actor|
          @actor_collisions << actor if Collisions::aabb_rect_vs_rect(actor.rect, rect)
        end
      end

      # --- 3. Movement :
      @x += @dx
      @y += @dy
    end

    def reset(position)
      @x, @y        = position[0], position[1]
      @dx, @dy      = 0.0, 0.0
      @facing_right = position[2]

      @machine.start
    end

    def record_death_tick
      @death_tick = $gtk.args.state.tick_count
    end

    def is_dead?
      @machine.current_state == :death
    end
  end
end
