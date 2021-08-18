module Platformer
  class Room
    attr_reader :sector,
                :name, :symbol,
                :tile_width, :tile_height,
                :tiles,
                :pixel_width, :pixel_height,
                #:start_x, :start_y,
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

      puts @symbol
      json_data['layerInstances'].each do |layer|
        case layer['__identifier']
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
                animation[:current_step] = rand animation[:steps].length

              end
            end

            @animated_tiles << animation
          end

        when 'Exits'
          layer['entityInstances'].each do |exit_data|
            fields_data = exit_data['fieldInstances']
            @exits << { rect:             [ exit_data['px'][0],
                                            exit_data['px'][1],
                                            exit_data['width'],
                                            exit_data['height'] ],
                        orientation:      extract_field_value(fields_data, 'orientation').downcase.to_sym,
                        destination_name: extract_field_value(fields_data, 'room').downcase.to_sym,
                        destination_x:    extract_field_value(fields_data, 'x'),
                        destination_y:    extract_field_value(fields_data, 'y')  }
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
    end

    def extract_field_value(json_data,identifier)
      value = nil
      json_data.each do |field|
        value = field['__value'] if field['__identifier'] == identifier
      end

      value
    end


    # ---=== UPDATE : ===---
    def update(args)
      @animated_tiles.each do |tile|
        if args.tick_count % tile[:speed] == 0 then
          tile[:current_step] = ( tile[:current_step] + 1 ) % tile[:steps].length
        end
      end
    end


    # ---=== RENDER : ===---
    def render(args,scale)
      offset_x  = ( args.grid.right - @pixel_width  * scale ).div(2)
      offset_y  = ( args.grid.top   - @pixel_height * scale ).div(2)

      # Static tiles :
      args.outputs.sprites << { x:    offset_x,
                                y:    offset_y,
                                w:    @pixel_width * scale,
                                h:    @pixel_height * scale,
                                path: @symbol,
                                source_x: 0,
                                source_y: 0,
                                source_w: @pixel_width,
                                source_h: @pixel_height }

      # Animated tiles :
      args.outputs.sprites << @animated_tiles.map do |tile|
                                raw_tile      = tile[:steps][tile[:current_step]]

                                { x:        raw_tile[:x] * scale + offset_x,
                                  y:        raw_tile[:y] * scale + offset_y,
                                  w:        raw_tile[:w] * scale,
                                  h:        raw_tile[:h] * scale,
                                  path:     raw_tile[:path],
                                  source_x: raw_tile[:source_x],
                                  source_y: raw_tile[:source_y],
                                  source_w: raw_tile[:source_w],
                                  source_h: raw_tile[:source_h] }
                              end
    end


    # ---=== SERIALIZATION : ===---
    def serialize
      { name: @name, tile_width: @tile_width, tile_height: @tile_height, pixel_width: @pixel_width, pixel_height: @pixel_height }
    end

    def inspect() serialize.to_s  end
    def to_s()    serialize.to_s  end 
  end
end
