class Player < Actor
  GRAVITY = -0.4

  # ---=== INITIALISATION : ===---
  def initialize(animation,fsm,start_x,start_y,health)
    super(animation,fsm,start_x,start_y)
    
    @health = health
  end
  

  # ---=== UPDATE : ===---
  def update(args,room)

    # --- 1. Updating state :
    @machine.update(args)
    @animation.update


    # --- 3. Collisions :
    @collision_rects  = surrounding_tiles(room)
    @dx, @dy  = Collisions::resolve_collisions_with_rects [ @x, @y ],
                                                          [ @animation.width, @animation.height],
                                                          [ @dx, @dy ],
                                                          @collision_rects

    @x += @dx
    @y += @dy
  end


  # ---=== COLLISIONS : ===---
  def surrounding_tiles(room)
    # --- Player start tile :
    tile_size                 = room.sector.tileset.tile_size
    tile_x, tile_y            = Utilities::pixel_to_tile  @x, @y, tile_size

    # --- Player end tile :
    next_tile_x, next_tile_y  = Utilities::pixel_to_tile  @x + @dx, @y + @dy, tile_size

    #puts "tile: #{tile_x},#{tile_y} - next tile: #{next_tile_x},#{next_tile_y}"
    if    @dx > 0 then  next_tile_x += 1
    elsif @dx < 0 then  next_tile_x -= 1
    end

    if    @dy > 0 then  next_tile_y += 1
    elsif @dy < 0 then  next_tile_y -= 1
    end

    # --- Movement / Potential collision zone :
    left    = [ tile_x, next_tile_x ].min
    right   = left + ( tile_x - next_tile_x ).abs
    bottom  = [ tile_y, next_tile_y ].min
    top     = bottom + ( tile_y - next_tile_y ).abs


    # --- List of collidable rects :
    rects = []
    #bottom.upto(top) do |row|
    (tile_y - 1).upto(tile_y + 1) do |row|
      #left.upto(right) do |column|
      (tile_x - 1).upto(tile_x + 1) do |column|
        if room.coords_inside? column, row then        
          case room.tile_type_at( column, row )
          when :wall      then  rects << [ column * tile_size, row * tile_size, tile_size, tile_size ]
          when :platform  then  rects << [ column * tile_size, row * tile_size, tile_size, tile_size ] if @dy <= 0
          end
        end
      end
    end
    #puts '------'

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
