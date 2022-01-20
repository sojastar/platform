class Actor
  MAX_REPLAY_LENGTH = 32

  attr_sprite
  attr_accessor :dx, :dy,
                :machine,
                :animation

  # ---=== INITIALISATION : ===---
  def initialize(animation,fsm,start_x,start_y,health)
    @animation    = animation
    
    @machine      = fsm
    @machine.set_parent self
    @machine.start

    @x, @y        = start_x, start_y
    @dx, @dy      = 0, 0

    @health       = health

    @moves        = []
    @mode         = :play
    @replay_head  = 0
    @replay_speed = MAX_REPLAY_LENGTH
  end


  # ---=== UPDATE : ===---
  def update(args)
    @machine.update(args) unless @machine.nil?
    @animation.update     unless @animation.nil?
  end


  # ---=== COLLISIONS : ===---
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
            rects << [ column * tile_size, row * tile_size, tile_size, tile_size ] if ( @dy <= 0 && (@y - @animation.height / 2) >= (row + 1) * room.sector.tileset.tile_size )
          when :lader
            rects << [ column * tile_size, row * tile_size, tile_size, tile_size ] if ( @dy <= 0 && (@y - @animation.height / 2) >= (row + 1) * room.sector.tileset.tile_size )
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
