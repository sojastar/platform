class Room
  TYPES = [ :empty,
            :block,
            :platform ]

  attr_reader :tile_size,
              :start_x, :start_y,
              :exits
  
  # ---=== INITIALISATION : ===---
  def initialize
    @start_x, @start_y  = -1, -1
    @exits              = []
  end

  def set_tiles(tiles_path,tiles_json_file) # Be carefull ! The json file and ...
                                            # ... the png file must be in the ...
                                            # ... same directory !!!
    raw_data          = $gtk.read_file  tiles_path + '/' + tiles_json_file
    tiles_data        = $gtk.parse_json raw_data
    
    @tilesheet        = tiles_path + '/' + tiles_data["image"]
    @tilesheet_height = tiles_data["columns"]
    @tilesheet_width  = tiles_data["tilecount"].div( tiles_data["columns"] )
    @tile_size        = tiles_data["tilewidth"]

    @tiles_types      = tiles_data["tiles"].map do |tile|
                          TYPES[tile["properties"][0]["value"].to_i]
                        end
  end

  def set_start_position(x,y)
    @start_x, @start_y  = @tile_size * x, @tile_size * y
  end

  def set_tilemaps(csv_files)
    @tilemaps         = []
    @current_tilemap  = 0
    csv_files.each do |csv_file|
      # Data :
      csv_data    =  $gtk.read_file(csv_file)
      layer_tiles = csv_data.split("\n").reverse.map { |line| line.split(',').map { |tile_index| tile_index.to_i } }

      # Graphics :
      layer_name  = csv_file.split('/').last.split('.').first.to_sym
      $gtk.args.render_target(layer_name).width  = layer_tiles.first.length  * @tile_size
      $gtk.args.render_target(layer_name).height = layer_tiles.length        * @tile_size
      layer_tiles.each.with_index do |row,y|
        row.each.with_index do |tile_index,x|
          $gtk.args.render_target(layer_name).sprites << blit_tile( tile_index, x, y ) unless tile_index == -1
        end
      end

      @tilemaps << { tiles: layer_tiles, render_target: layer_name }
    end
  end

  def set_animation_speed(speed)
    @animation_speed  = speed
  end    

  def add_exit(exit_tiles,next_sector,next_room)
    # This algorihtm assumes that all exits are on the edge of the map ...
    # ... and therefore that the zones are fully vertical or fully    ...
    # ... horizontal and that the tilemaps is already defined!!!
    puts "Trying to add door to room #{next_room} in sector #{next_sector}"
    collision_rect =  if    exit_tiles.first[0] == exit_tiles.last[0] then  # exit is vertical
                        bottom  = [ exit_tiles.first[1], exit_tiles.last[1] ].min
                        top     = [ exit_tiles.first[1], exit_tiles.last[1] ].max

                        if    exit_tiles.first[0] == 0 then                 # exit on the left side
                          [        -@tile_size, bottom * @tile_size, @tile_size, ( top - bottom + 1 ) * @tile_size ]
                        elsif exit_tiles.first[0] == tile_width - 1 then         # exit on the right side
                          [ pixel_width, bottom * @tile_size, @tile_size, ( top - bottom + 1 ) * @tile_size ]
                        else
                          raise "ERROR: exit not on the edge of the room!"
                        end

                      elsif exit_tiles.first[1] == exit_tiles.last[1] then  # exit is horizontal
                        left  = [ exit_tiles.first[0], exit_tiles.last[0] ].min
                        right = [ exit_tiles.first[0], exit_tiles.last[0] ].max

                        if    exit_tiles.first[1] == 0 then                 # exit on the bottom
                          [ left * @tile_size,         -@tile_size, ( right - left + 1 ) * @tile_size, @tile_size ]
                        elsif exit_tiles.first[1] == tile_height - 1 then        # exit on the bottom
                          [ left * @tile_size, pixel_height, ( right - left + 1 ) * @tile_size, @tile_size ]
                        else
                          raise "ERROR: exit not on the edge of the room!"
                        end

                      else
                        raise "ERROR: exit tiles are not aligned."

                      end

    @exits << { collision_rect: collision_rect, next_sector: next_sector, next_room: next_room }
  end

  def self.create_room(&block)
    if block.nil? then
      raise "ERROR: trying to create new room but no block given."

    else
      new_room = Room.new
      new_room.instance_eval &block

      raise "ERROR: newly created room doesn't have a png tiles file. Did you forget to set one?" unless  new_room.instance_variable_defined?(:@tilesheet)
      raise "ERROR: newly created room doesn't have a tilemap. Did you forget to set one?"        unless  new_room.instance_variable_defined?(:@tilemaps)
      raise "ERROR: newly created room doesn't have any exits. Did you forget to add some?"       if      new_room.exits.empty?

      new_room
    end
  end


  # ---=== ACCESORS : ===---
  def tile_width()      @tilemaps.first[:tiles].first.length                    end
  def tile_height()     @tilemaps.first[:tiles].length                          end
  def pixel_width()     @tile_size * tile_width                                 end
  def pixel_height()    @tile_size * tile_height                                end
  def tile_id_at(x,y)   @tilemaps[@current_tilemap][:tiles][y][x]               end
  def tile_type_at(x,y) @tiles_types[@tilemaps[@current_tilemap][:tiles][y][x]] end


  # ---=== UPDATE : ===---
  def update(args,player)
    @current_tilemap = ( @current_tilemap + 1 ) % @tilemaps.length if args.tick_count % @animation_speed == 0
  end


  # ---=== RENDER : ===---
  def render(args,player)

    # --- 1. Backgrounds :
    
    # --- 2. Tiles :
    args.render_target(:room_content).sprites <<  { x:        0,
                                                    y:        0,
                                                    w:        pixel_width,
                                                    h:        pixel_height,
                                                    path:     @tilemaps[@current_tilemap][:render_target],
                                                    source_x: 0,
                                                    source_y: 0,
                                                    source_w: pixel_width,
                                                    source_h: pixel_height }

    # --- 3. Enemies, projectiles, traps, stuff... :
    

    # --- 4. Player :
    args.render_target(:room_content).sprites <<  player.render(args)

    :room_content
  end

  def blit_tile(tile_index,x,y)
    { x:        x * @tile_size,
      y:        y * @tile_size,
      w:        @tile_size,
      h:        @tile_size,
      path:     @tilesheet,
      source_x: ( tile_index % @tilesheet_width ) * @tile_size,
      source_y: ( @tilesheet_height - tile_index.div( @tilesheet_width ) - 1 ) * @tile_size,
      source_w: @tile_size,
      source_h: @tile_size }
  end


  # ---=== EXITS : ===---
  def exit(tile_x,tile_y)
  end


  # ---=== SERIALIZATION : ===---
  def serialize
    { tile_width: tile_width, tile_height: tile_height, pixel_width: pixel_width, pixel_height: pixel_height }
  end

  def inspect() serialize.to_s  end
  def to_s()    serialize.to_s  end 
end
