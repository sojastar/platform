require           'minitest/autorun'
require_relative  'test_helper.rb'

describe Platformer::Room do
  it 'is created from json data' do
    json_data = $gtk.parse_json_file '../assets/sectors/sector1.ldtk'
    s         = DummySector.new json_data
    r         = Platformer::Room.new s, json_data['levels'].first

    ### General Stuff :
    assert_equal  s,  r.sector

    assert_equal  128, r.pixel_width
    assert_equal   64, r.pixel_height

    assert_equal  16, r.tile_width
    assert_equal   8, r.tile_height

    assert_equal  56, r.start_x
    assert_equal  48, r.start_y

    ### Tilemap :
    assert_equal   8, r.tiles.length
    assert_equal  16, r.tiles.first.length
    assert_equal  16, r.tiles.last.length

    assert_equal   0, r.tiles[7][0]
    assert_equal  28, r.tiles[7][1]

    ### Render target :
    assert_equal             128, $gtk.args.render_target(r.symbol).sprites.length
    assert_equal               8, $gtk.args.render_target(r.symbol).sprites[1][:x]
    assert_equal              56, $gtk.args.render_target(r.symbol).sprites[1][:y]
    assert_equal               8, $gtk.args.render_target(r.symbol).sprites[1][:w]
    assert_equal               8, $gtk.args.render_target(r.symbol).sprites[1][:h]
    assert_equal  s.tileset.file, $gtk.args.render_target(r.symbol).sprites[1][:path]
    assert_equal              32, $gtk.args.render_target(r.symbol).sprites[1][:source_x]
    assert_equal              32, $gtk.args.render_target(r.symbol).sprites[1][:source_y]
    assert_equal               8, $gtk.args.render_target(r.symbol).sprites[1][:source_w]
    assert_equal               8, $gtk.args.render_target(r.symbol).sprites[1][:source_h]

    ### Exits :
    assert_equal  2, r.exits.length

    assert_equal  [120, 24, 128, 64], r.exits.first[:rect]
    assert_equal              :room1, r.exits.first[:destination_name]
    assert_equal                   0, r.exits.first[:destination_x]
    assert_equal                  32, r.exits.first[:destination_y]
    assert_equal              [1, 0], r.exits.first[:destination_offset]

    ### Animated Tiles :
    assert_equal  3, r.animated_tiles.length

    assert_equal       2, r.animated_tiles[0][:steps].length
    assert_equal       0, r.animated_tiles[0][:current_step]
    assert_equal      10, r.animated_tiles[0][:speed]
  end

  it 'can check if tile coordinates are inside or not' do
    json_data = $gtk.parse_json_file '../assets/sectors/sector1.ldtk'
    s         = DummySector.new json_data
    r         = Platformer::Room.new s, json_data['levels'].first

    refute  r.coords_inside? -1,  0
    refute  r.coords_inside?  0, -1
    assert  r.coords_inside?  0,  0
    assert  r.coords_inside? 15,  7
    refute  r.coords_inside? 16,  7
    refute  r.coords_inside? 15,  8
  end
end
