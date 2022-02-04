module Platformer
  class Actor
    MAX_REPLAY_LENGTH = 32
  
    attr_sprite
    attr_accessor :dx, :dy

    attr_reader :machine,
                :animation,
                :facing_right,
                :is_enabled
  
    # ---=== INITIALISATION : ===---
    def initialize(animation,fsm,size,start_position,health)
      @animation    = animation
      
      @machine      = fsm
      @machine.set_parent self

      @size         = size
  
      @x, @y        = start_position
      @dx         ||= 0.0
      @dy         ||= 0.0

      @facing_right = true

      @is_enabled   = true

      @health       = health
    end
  
  
    # ---=== UPDATE : ===---
    def update(args)
      @machine.update(args) unless @machine.nil?
      @animation.update     unless @animation.nil?
    end

    def current_state
      @machine.current_state
    end

    def enable()  @is_enabled = true  end
    def disable() @is_enabled = false end
  
  
    # ---=== COLLISIONS : ===---
    def rect
      [ @x, @y, @size[0], @size[1] ]
    end

    def surrounding_tiles(room)
      # --- Player start tile :
      tile_size                 = room.sector.tileset.tile_size
      tile_x, tile_y            = Utilities::pixel_to_tile  @x, @y, tile_size
  
      # --- List of collidable rects :
      rects = []
      (tile_y - 1).upto(tile_y + 1) do |row|
        (tile_x - 1).upto(tile_x + 1) do |column|
          if room.coords_inside? column, row then
            case room.tile_type_at( column, row )
            when :wall
              rects << [ column * tile_size, row * tile_size, tile_size, tile_size ]
            when :platform
              if  ( @dy <= 0 && (@y - @animation.height / 2) >= (row + 1) * tile_size )
                rects << [ column * tile_size, row * tile_size, tile_size, tile_size ]
              end
            end
          end
        end
      end
  
      bottom_tile = room.tile_type_at tile_x, tile_y - 1
  
      [ rects, bottom_tile ]
    end
  
  
    # ---=== RENDER : ===---
    def render(args)
      @animation.frame_at @x - @animation.width  / 2,
                          @y - @animation.height / 2,
                          !@facing_right
    end
  
  
    # ---=== SERIALIZATION : ===---
    def serialize
      { x: @x, y:@y }
    end
  
    def inspect() serialize.to_s  end
    def to_s()    serialize.to_s  end 
  end
end
