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

      json_data['layerInstances'].each do |layer|
        case layer['__identifier']
        when 'Animated_Tiles'
          layer['entityInstances'].map do |animated_tile|
            animation = { steps:        [],
                          current_step: 0,
                          speed:        10,
                          type:         '' }

            animated_tile['fieldInstances'].each do |field|
              case field['__identifier']
              when /^animation_tile/
                step_tile = field['__value']
                source    = @sector.tileset.tile_coordinates(step_tile)

                animation[:steps] <<  { x:        animated_tile['px'][0],
                                        y:        animated_tile['px'][1],
                                        w:        animated_tile['width'],
                                        h:        animated_tile['height'],
                                        file:     @sector.tileset.file,
                                        source_x: source[0],
                                        source_y: source[1],
                                        source_w: @sector.tileset.tile_size,
                                        source_h: @sector.tileset.tile_size }

              when /^type/
                animation[:type] = field['__value'].downcase.to_sym

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
            $gtk.args.render_target(@symbol).sprites << { x:        tile['px'][0],
                                                          y:        @pixel_height - ( tile['px'][1] + 1 ) * @sector.tileset.tile_size,
                                                          w:        @sector.tileset.tile_size,
                                                          h:        @sector.tileset.tile_size,
                                                          file:     @sector.tileset.file,
                                                          source_x: tile['src'][0],
                                                          source_y: tile['src'][1],
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
    def render(args,x,y)
      # Static tiles :
      args.outputs.sprites << { x:    x,
                                y:    y,
                                w:    @pixel_width,
                                h:    @pixel_height,
                                file: @symbol,
                                source_x: 0,
                                source_y: 0,
                                source_w: @pixel_width,
                                source_h: @pixel_height }

      # Animated tiles :
      arg.outputs.sprites <<  @animated_tiles.map do |tile|
                                tile[:steps][tile[:current_step]]
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
