class Player < Actor
  GRAVITY = -0.4

  # ---=== INITIALISATION : ===---
  def initialize(animation,fsm,start_x,start_y,health)
    super(animation,fsm,start_x,start_y)
    
    @health = health
  end
  

  # ---=== UPDATE : ===---
  def update(args,sector)

    # --- 1. Updating state :
    @machine.update(args)
    @animation.update


    # --- 3. Collisions :
    @collision_rects  = surrounding_tiles(sector.current_room)
    @dx, @dy  = Collisions::resolve_collisions_with_rects [ @x, @y ],
                                                          [ @animation.width, 8],#@animation.width ],
                                                          [ @dx, @dy ],
                                                          @collision_rects

    @x += @dx
    @y += @dy
  end


  # ---=== COLLISIONS : ===---
  def surrounding_tiles(room)
    # --- Player start tile :
    tile_size                 = room.tile_size
    tile_x, tile_y            = Utilities::pixel_to_tile  @x, @y, tile_size

    # --- Player end tile :
    next_tile_x, next_tile_y  = Utilities::pixel_to_tile  @x + @dx, @y + @dy, tile_size

    if @dx >= 0 then  next_tile_x += 1
    else              next_tile_x -= 1
    end

    if @dy >= 0 then  next_tile_y += 1
    else              next_tile_y -= 1
    end

    # --- Movement / Potential collision zone :
    left    = [ tile_x, next_tile_x ].min
    right   = left + ( tile_x - next_tile_x ).abs
    bottom  = [ tile_y, next_tile_y ].min
    top     = bottom + ( tile_y - next_tile_y ).abs


    # --- List of collidable rects :
    rects = []
    bottom.upto(top) do |row|
      left.upto(right) do |column|
        case room.tile_type_at( column, row )
        when :block     then  rects << [ column * tile_size, row * tile_size, tile_size, tile_size ]
        when :platform  then  rects << [ column * tile_size, row * tile_size, tile_size, tile_size ]
        end
      end
    end

    rects
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
