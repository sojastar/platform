module Platformer
  class Room
    attr_reader :sector,
                :name, :symbol,
                :tile_width, :tile_height,
                :tiles,
                :pixel_width, :pixel_height,
                :start_position,
                :exits,
                :animated_tiles,
                :actors,
                :items

    attr_accessor :last_entry_point

    # ---=== INITIALISATION : ===---
    def initialize(sector,json_data)
      @sector         = sector

      @name           = json_data['identifier']
      @symbol         = @name.downcase.to_sym

      @pixel_width    = json_data['pxWid']
      @pixel_height   = json_data['pxHei']

      @tile_size      = @sector.tileset.tile_size
      @tile_width     = json_data['pxWid'] / @tile_size
      @tile_height    = json_data['pxHei'] / @tile_size

      @tiles          = []
      @exits          = []
      @animated_tiles = []
      @actors         = []
      @platforms      = []
      @items          = []

      @start_position = [ 0, 0 ]

      @last_entry_point = [ 0, 0, true ]

      json_data['layerInstances'].each do |layer|
        case layer['__identifier']
        when 'Spawn'
          layer['entityInstances'].each do |spawn_point|
            case spawn_point['__identifier']
            when 'PlayerSpawn'
              start_x           = spawn_point['px'][0]
              start_y           = @pixel_height - spawn_point['px'][1]
              @start_position   = [ start_x, start_y ]
              @last_entry_point = [ start_x, start_y, true ]

            when 'ActorSpawn'
              spawn_x = spawn_point['px'][0]
              spawn_y = @pixel_height - spawn_point['px'][1]
              type    = extract_field_value(spawn_point['fieldInstances'], 'type').capitalize
              health  = extract_field_value(spawn_point['fieldInstances'], 'health').to_i
              path    = extract_field_value(spawn_point['fieldInstances'], 'path').map do |point|
                          [                 point['cx'] * @tile_size + @tile_size / 2,
                            @pixel_height - point['cy'] * @tile_size - @tile_size / 2 ]
                        end 
              speed   = extract_field_value(spawn_point['fieldInstances'], 'speed').to_f

              @actors << Object::const_get(type).spawn_at(  [ spawn_x, spawn_y ],
                                                            [ @tile_size, @tile_size ],
                                                            health,
                                                            path,
                                                            speed )

            when 'PlatformSpawn'
              spawn_x   = spawn_point['px'][0]
              spawn_y   = @pixel_height - spawn_point['px'][1]
              type      = extract_field_value(spawn_point['fieldInstances'], 'type').capitalize
              nodes     = extract_field_value(spawn_point['fieldInstances'], 'path').map do |point|
                            [                 point['cx'] * @tile_size + @tile_size / 2,
                              @pixel_height - point['cy'] * @tile_size - @tile_size / 2 ]
                          end 
              loop_type = extract_field_value(spawn_point['fieldInstances'], 'loop').downcase.to_sym
              pause     = extract_field_value(spawn_point['fieldInstances'], 'pause').to_f
              speed     = extract_field_value(spawn_point['fieldInstances'], 'speed').to_f

              @platforms  << Object::const_get(type).spawn_at(  [ spawn_x, spawn_y ],
                                                                [ @tile_size, @tile_size ],
                                                                Path.new(nodes, loop_type, pause),
                                                                speed )

            when 'Item'
              place_x = spawn_point['px'][0]
              place_y = @pixel_height - spawn_point['px'][1]
              type    = extract_field_value(spawn_point['fieldInstances'], 'type').capitalize
              single  = extract_field_value(spawn_point['fieldInstances'], 'single')

              @items << Object::const_get(type).place_at( [ place_x, place_y ],
                                                          [ @tile_size, @tile_size ],
                                                          single )

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

      reset(player) if player.is_dead? && args.state.tick_count - player.death_tick >= RESPAWN_TIME

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

      # Actors :
      @actors.each { |actor| actor.update args, self }

      # Platforms :
      @platforms.each { |platform| platform.update args, self }

      # Items :
      @items.each { |item| item.update args }
    end

    def reset(player)
      player.reset @last_entry_point
      @actors.each { |actor| actor.reset }
      @platforms.each { |platform| platform.reset }
      @items.each do |item|
        item.reset unless item.single                             &&
                          player.owned_items.has_key?(item.type)  &&
                          player.owned_items[item.type] >= 1
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

      # Actors :
      args.render_target(:final).sprites << @actors.map { |actor| actor.render(args) if actor.is_enabled }

      # Platforms :
      args.render_target(:final).sprites << @platforms.map { |platform| platform.render(args) if platform.is_enabled }

      # Items :
      args.render_target(:final).sprites << @items.map { |item| item.render(args) if item.is_enabled }

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
