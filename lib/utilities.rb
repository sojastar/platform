module Utilities
  # ---=== COORDINATES : ===---
  def self.pixel_to_tile(x,y,tile_size) [ x.div(tile_size).to_i, y.div(tile_size).to_i ]  end
  def self.tile_to_pixel(x,y,tile_size) [ x * tile_size, y * tile_size ]                  end
end
