require           'minitest/autorun'
require_relative  'test_helper.rb'

describe Platformer::TileSet do
  it 'is created from json data' do
    json_data = $gtk.parse_json_file '../assets/sectors/sector1.ldtk'

    # We assume there is only one tileset per sector.
    t         = Platformer::TileSet.new json_data['defs']['tilesets'].first

    assert_equal  'assets/sprites/sector1_tileset.png',  t.file
    
    assert_equal  8,  t.tile_size

    assert_equal  8,  t.width
    assert_equal  8,  t.height

    assert        t.types.has_key? :empty
    assert_equal  [25, 26, 61, 62, 63], t.types[:empty]

    assert        t.types.has_key? :wall
    assert_equal  [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12,
                   13, 14, 15, 19, 20, 21, 22, 23, 27, 28, 29,
                   30, 31, 38, 39, 40, 42, 48, 50, 56, 57, 58], t.types[:wall]

    assert        t.types.has_key? :platform
    assert_equal  [16, 17, 18, 24], t.types[:platform]

    assert        t.types.has_key? :lader
    assert_equal  [], t.types[:lader]

    assert        t.types.has_key? :water
    assert_equal  [41, 43, 49, 51], t.types[:water]

    assert_equal  [ 0, 56], t.tile_coordinates(0)
    assert_equal  [56, 56], t.tile_coordinates(7)
    assert_equal  [ 0, 48], t.tile_coordinates(8)
    assert_equal  [56,  0], t.tile_coordinates(63)

    assert_equal         64, t.tiles.length
    assert_equal      :wall, t.tiles[0]
    assert_equal  :platform, t.tiles[24]
    assert_equal     :water, t.tiles[41]
    assert_equal     :empty, t.tiles[61]
  end
end
