class Player < Actor
  MAX_REPLAY_LENGTH = 32
  attr_accessor :x, :y

  # ---=== INITIALISATION : ===---
  def initialize(animation,fsm,start_x,start_y,health)
    super(animation,fsm,start_x,start_y)
    
    @health = health

    @moves        = []
    @mode         = :play
    @replay_head  = 0
    @replay_speed = MAX_REPLAY_LENGTH
  end
  

  # ---=== UPDATE : ===---
  def update(args,room)

    # --- 1. Updating state :
    @machine.update(args)
    @animation.update


    # --- 3. Collisions :
    collision_rects, bottom_tile  = surrounding_tiles(room)
    @dx, @dy, diagonal            = Collisions::resolve_collisions_with_rects [ @x, @y ],
                                                                              [ @animation.width, @animation.height],
                                                                              [ @dx, @dy ],
                                                                              collision_rects

    @dx, @dy = 0.0, -1.0 if diagonal && bottom_tile == :empty

    @x += @dx
    @y += @dy
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
