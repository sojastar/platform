module Platformer
  class TileSet
    attr_reader :file,
                :tile_size,
                :width, :height,
                :types

    def initialize(json_data)
      @file       = json_data['relPath'][3..-1]

      @tile_size  = json_data['tileGridSize']

      @width      = json_data['pxWid'] / @tile_size
      @height     = json_data['pxHei'] / @tile_size

      @types      = json_data['enumTags'].map do |entry|
                      [ entry['enumValueId'].downcase.to_sym, entry['tileIds'] ]
                    end
                    .to_h
    end
  end
end
