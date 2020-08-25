require           'minitest/autorun'
require_relative  'test_helper.rb'

describe Room do
  it 'is created with a description block' do
    room  = Room::create_room do
              set_tiles           '../sprites/tiles.png', 8, 8, 8
              set_tilemaps        [ '../sprites/map16x8_tile_layer1.csv',
                                    '../sprites/map16x8_tile_layer2.csv' ]
              set_animation_speed 20
              set_start_position  14, 2
              add_exit            [ [ 2,7], [ 5,7] ], :sector1, :room16x16
              add_exit            [ [15,3], [15,5] ], :sector1, :room8x8
            end

    assert_equal  '../sprites/tiles.png', room.instance_variable_get(:@tilesheet)
    assert_equal  8,                      room.instance_variable_get(:@tilesheet_width)
    assert_equal  8,                      room.instance_variable_get(:@tilesheet_height)
    assert_equal  8,                      room.instance_variable_get(:@tile_size)

    tilemaps  = room.instance_variable_get(:@tilemaps)
    assert_equal   2,                   tilemaps.length
    assert_equal  16,                   tilemaps[0][:tiles].first.length
    assert_equal   8,                   tilemaps[0][:tiles].length
    assert_equal  :map16x8_tile_layer1, tilemaps[0][:render_target]
    assert_equal  16,                   tilemaps[1][:tiles].first.length
    assert_equal   8,                   tilemaps[1][:tiles].length
    assert_equal  :map16x8_tile_layer2, tilemaps[1][:render_target]

    assert_equal  16, room.width
    assert_equal   8, room.height

    assert_equal  14, room.start_x
    assert_equal   2, room.start_y

    assert_equal  2, room.exits.length
  end

  it 'will create its exit collision rectangles' do
    room  = Room::create_room do
              set_tiles           '../sprites/tiles.png', 8, 8, 8
              set_tilemaps        [ '../sprites/map8x8.csv' ]
              set_animation_speed 20
              set_start_position  5, 1
              add_exit            [ [0,3],[0,5] ], :sector1, :room4   # left exit
              add_exit            [ [7,2],[7,6] ], :sector2, :room3   # right exit
              add_exit            [ [3,0],[5,0] ], :sector3, :room2   # bottom exit
              add_exit            [ [2,7],[4,7] ], :sector4, :room1   # top exit
            end

    assert_equal   4, room.exits.length 

    # Left exit :
    assert_equal  -8, room.exits[0][:collision_rect][0]
    assert_equal  24, room.exits[0][:collision_rect][1]
    assert_equal   8, room.exits[0][:collision_rect][2]
    assert_equal  24, room.exits[0][:collision_rect][3]

    # Right exit :
    assert_equal  64, room.exits[1][:collision_rect][0]
    assert_equal  16, room.exits[1][:collision_rect][1]
    assert_equal   8, room.exits[1][:collision_rect][2]
    assert_equal  40, room.exits[1][:collision_rect][3]

    # Bottom exit :
    assert_equal  24, room.exits[2][:collision_rect][0]
    assert_equal  -8, room.exits[2][:collision_rect][1]
    assert_equal  24, room.exits[2][:collision_rect][2]
    assert_equal   8, room.exits[2][:collision_rect][3]

    # Top exit :
    assert_equal  16, room.exits[3][:collision_rect][0]
    assert_equal  64, room.exits[3][:collision_rect][1]
    assert_equal  24, room.exits[3][:collision_rect][2]
    assert_equal   8, room.exits[3][:collision_rect][3]
  end
end
