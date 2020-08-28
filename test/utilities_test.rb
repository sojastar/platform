require           'minitest/autorun'
require_relative  'test_helper.rb'

describe Utilities do
  it 'can convert from pixel to tile coordinates' do
    tile_size       = 8
    pixel_x         = 47
    pixel_y         = 29
    tile_x, tile_y  = Utilities::pixel_to_tile pixel_x, pixel_y, tile_size

    assert_equal  5, tile_x
    assert_equal  3, tile_y
  end

  it 'can convert from tile to pixel coordinates' do
    tile_size       = 8
    tile_x          = 2
    tile_y          = 7
    pixel_x, pixel_y  = Utilities::tile_to_pixel tile_x, tile_y, tile_size

    assert_equal  16, pixel_x
    assert_equal  56, pixel_y
  end
end

