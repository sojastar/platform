module Platformer
  class Player < Actor
    attr_reader :death_tick,
                :collected_items,
                :owned_items

    # ---=== INITIALISATION : ===---
    def initialize(animation,fsm,size,start_position,health)
      super animation, fsm, size, start_position, health

      @actor_collisions = []
      @collected_items  = {}
      @owned_items      = {}

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

      # - 2.2 With other actors and items :
      unless is_dead? then
        # - Actors :
        @actor_collisions = []
        room.actors.each do |actor|
          @actor_collisions << actor if Collisions::aabb_rect_vs_rect(actor.rect, rect)
        end

        # - Items :
        room.items.each do |item|
          if item.is_enabled then
            if Collisions::aabb_rect_vs_rect(item.rect, rect) then
              @collected_items[item.type] ||= 0
              @collected_items[item.type]  += 1

              item.disable
            end
          end
        end
      end

      # --- 3. Movement :
      @x += @dx
      @y += @dy
    end

    def reset(position)
      @actor_collisions = []
      @x, @y            = position[0], position[1]
      @dx, @dy          = 0.0, 0.0
      @facing_right     = position[2]

      @collected_items  = {}

      @machine.start
    end

    def record_death_tick
      @death_tick = $gtk.args.state.tick_count
    end

    def is_dead?
      @machine.current_state == :death
    end


    # ---=== ITEMS : ===---
    def owns(type)
      @owned_items.has_key? type
    end

    def collected(type)
      @collected_items.has_key? type
    end

    def add_collected_to_owned
      @collected_items.each_pair do |type,count|
        @owned_items[type] ||= 0
        @owned_items[type]  += count
      end
    end
  
  
    # ---=== SERIALIZATION : ===---
    def serialize
      { x: @x, y:@y, collected: @collected_items, owned: @owned_items }
    end
  
    def inspect() serialize.to_s  end
    def to_s()    serialize.to_s  end 
  end
end
