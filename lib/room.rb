module Platformer
  class Room
    attr_reader :sector,
                :name, :symbol,
                :tile_width, :tile_height,
                :tiles,
                :pixel_width, :pixel_height,
                :start_x, :start_y,
                :exits,
                :animated_tiles

    # ---=== INITIALISATION : ===---
    def initialize(sector,json_data)
      @sector         = sector

      @name           = json_data['identifier']
      @symbol         = @name.downcase.to_sym

      @pixel_width    = json_data['pxWid']
      @pixel_height   = json_data['pxHei']

      @tile_width     = json_data['pxWid'] / @sector.tileset.tile_size
      @tile_height    = json_data['pxHei'] / @sector.tileset.tile_size

      @tiles          = []
      @exits          = []
      @animated_tiles = []

      @start_x        = 0
      @start_y        = 0

      json_data['layerInstances'].each do |layer|
        case layer['__identifier']
        when 'Spawn'
          layer['entityInstances'].each do |spawn_point|
            case spawn_point['__identifier']
            when 'PlayerSpawn'
              @start_x  = spawn_point['px'][0]
              @start_y  = @pixel_height - spawn_point['px'][1]

            when 'ActorSpawn'
              puts 'Spawning actors one day'

            end
          end

        when 'Animated_Tiles'
          layer['entityInstances'].map do |animated_tile|
            animation = { steps:        [],
                          current_step: 0,
                          speed:        10 }

            animated_tile['fieldInstances'].each do |field|
              case field['__identifier']
              when 'speed'
                animation['speed'] = field['__value']

              when 'tiles'
                animation[:steps] = field['__value'].map do |index|
                                      source    = @sector.tileset.tile_coordinates(index)

                                      { x:        animated_tile['px'][0],
                                        y:        @pixel_height - animated_tile['px'][1] - @sector.tileset.tile_size,
                                        w:        animated_tile['width'],
                                        h:        animated_tile['height'],
                                        path:     @sector.tileset.file,
                                        source_x: source[0],
                                        source_y: source[1],
                                        source_w: @sector.tileset.tile_size,
                                        source_h: @sector.tileset.tile_size }
                                    end

              when 'random_start'
                animation[:current_step] = rand(animation[:steps].length) if field['__value']

              end
            end

            @animated_tiles << animation
          end

        when 'Exits'
          layer['entityInstances'].each do |exit_data|
            fields_data = exit_data['fieldInstances']

            orientation = extract_field_value(fields_data, 'orientation').to_sym
            offset      = case orientation
                          when :up    then [ @sector.tileset.tile_size / 2, 1 - @sector.tileset.tile_size / 2]
                          when :left  then [ -1 + @sector.tileset.tile_size / 2, -@sector.tileset.tile_size / 2]
                          when :down  then [ @sector.tileset.tile_size / 2, -@sector.tileset.tile_size / 2]
                          when :right then [ 1 + @sector.tileset.tile_size / 2, -@sector.tileset.tile_size / 2]
                          else               [ 0,  0]
                          end

            @exits << { rect:               [ exit_data['px'][0],
                                              @pixel_height - exit_data['px'][1],
                                              exit_data['width'],
                                              exit_data['height'] ],
                        orientation:        orientation,
                        destination_name:   extract_field_value(fields_data, 'room').downcase.to_sym,
                        destination_x:      extract_field_value(fields_data, 'x') * @sector.tileset.tile_size,
                        # vvv !!! WILL BE UPDATED LATER BECAUSE THE   ...     !!! vvv
                        # vvv !!! ... DESTINATION ROOM MIGHT NOT HAVE ...     !!! vvv
                        # vvv !!! ... LOADED YET.                             !!! vvv
                        # vvv !!! SO THAT WILL BE DONE AT THE SECTOR  ...     !!! vvv 
                        # vvv !!! ... INIT LEVEL, AFTER ALL ROOMS ARE LOADED. !!! vvv
                        destination_y:      extract_field_value(fields_data, 'y') * @sector.tileset.tile_size,
                        destination_offset: offset  }
          end

        when 'Tiles'
          $gtk.args.render_target(@symbol).width  = json_data['pxWid']
          $gtk.args.render_target(@symbol).height = json_data['pxHei']

          layer['gridTiles'].each.with_index do |tile,index|

            # Filling the collisions tile array :
            @tiles << [] if index % @tile_width == 0
            @tiles[index.div @tile_width][index % @tile_width] = tile['t']

            # Filling the render target :
            tile_coordinates = @sector.tileset.tile_coordinates(tile['t'])

            $gtk.args.render_target(@symbol).sprites << { x:        tile['px'][0],
                                                          y:        @pixel_height - tile['px'][1] - @sector.tileset.tile_size,
                                                          w:        @sector.tileset.tile_size,
                                                          h:        @sector.tileset.tile_size,
                                                          path:     @sector.tileset.file,
                                                          source_x: tile_coordinates[0],
                                                          source_y: tile_coordinates[1],
                                                          source_w: @sector.tileset.tile_size,
                                                          source_h: @sector.tileset.tile_size }
          end

        end
      end

      # Have to account for the LDtk vs DragonRuby vertical orientation :
      @tiles.reverse!
    end

    def extract_field_value(json_data,identifier)
      value = nil
      json_data.each do |field|
        value = field['__value'] if field['__identifier'] == identifier
      end

      value
    end


    # ---=== ACCESSORS : ===---
    def tile_type_at(x,y)
      @sector.tileset.tiles[@tiles[y][x]]
    end

    def coords_inside?(x,y)
      x >= 0 && x < @tile_width && y >= 0 && y < @tile_height
    end


    # ---=== UPDATE : ===---
    def update(args,player)

      # Player :
      player.update args, self

      # Exits :
      @exits.each do |exit_data|
        should_exit = false
        case exit_data[:orientation]
        when :up
          should_exit = true if player.y - player.animation.height / 2 >= exit_data[:rect][1]

        when :right
          should_exit = true if player.x - player.animation.width / 2 >= exit_data[:rect][0]

        when :down
          should_exit = true if player.y + player.animation.height / 2 <= exit_data[:rect][1] + exit_data[:rect][3]

        when :left
          should_exit = true if player.x + player.animation.width / 2 <= exit_data[:rect][0] + exit_data[:rect][2]

        end

        if should_exit then
          @sector.move_to_room  exit_data[:destination_name],
                                player,
                                exit_data[:destination_x] + exit_data[:destination_offset][0],
                                exit_data[:destination_y] + exit_data[:destination_offset][1]
        end

      end

      # Animated Tiles :
      @animated_tiles.each do |tile|
        if args.tick_count % tile[:speed] == 0 then
          tile[:current_step] = ( tile[:current_step] + 1 ) % tile[:steps].length
        end
      end
    end


    # ---=== RENDER : ===---
    def render(args,player,scale)
      offset_x  = ( args.grid.right - @pixel_width  * scale ).div(2)
      offset_y  = ( args.grid.top   - @pixel_height * scale ).div(2)

      # Static tiles :
      args.render_target(:final).sprites << { x:        0,
                                              y:        0,
                                              w:        @pixel_width,
                                              h:        @pixel_height,
                                              path:     @symbol,
                                              source_x: 0,
                                              source_y: 0,
                                              source_w: @pixel_width,
                                              source_h: @pixel_height }

      # Animated tiles :
      args.render_target(:final).sprites << @animated_tiles.map do |tile|
                                              tile[:steps][tile[:current_step]]
                                            end

      # Player :
      args.render_target(:final).sprites << player.render(args) 

      # DEBUG - Exits :
      if args.state.debug then
        args.render_target(:final).borders << @exits.map do |exit_data|
                                                exit_data[:rect] + [ 0, 128, 255, 255 ]
                                              end
      end

      # Final render :
      args.outputs.sprites << { x:        offset_x,
                                y:        offset_y,
                                w:        @pixel_width * scale,
                                h:        @pixel_height * scale,
                                path:     :final,
                                source_x: 0,
                                source_y: 0,
                                source_w: @pixel_width,
                                source_h: @pixel_height }
    end


    # ---=== SERIALIZATION : ===---
    def serialize
      { name: @name, tile_width: @tile_width, tile_height: @tile_height, pixel_width: @pixel_width, pixel_height: @pixel_height }
    end

    def inspect() serialize.to_s  end
    def to_s()    serialize.to_s  end 
  end
end
