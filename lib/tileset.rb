module Platformer
  class TileSet
    attr_reader :file,
                :tile_size,
                :width, :height,
                :types,
                :tiles

    def initialize(json_data)
      @file       = 'assets/' + json_data['relPath'][3..-1]

      @tile_size  = json_data['tileGridSize']

      @width      = json_data['pxWid'] / @tile_size
      @height     = json_data['pxHei'] / @tile_size

      @types      = json_data['enumTags'].map do |entry|
                      [ entry['enumValueId'].downcase.to_sym, entry['tileIds'] ]
                    end
                    .to_h

      @tiles      = []
      @types.each_pair do |type,tiles_list|
        tiles_list.each do |tile_index|
          @tiles[tile_index] = type
        end
      end
    end

    def tile_coordinates(index)
      [ ( index % @width ) * @tile_size,
        ( @height - index.div(@width) - 1 ) * @tile_size ]
    end
  end
end
