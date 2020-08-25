require           'minitest/autorun'
require_relative  'test_helper.rb'

describe Room do
  def setup
    @sector = Sector::create_sector do
                add_room(:room1) do
                  set_tiles           '../sprites/tiles.png', 8, 8, 8
                  set_tilemaps        [ '../sprites/map8x8.csv' ]
                  set_animation_speed 20
                  set_start_position  5, 1
                  add_exit            [ [0,3],[0,5] ], :sector1, :room4   # left exit
                  add_exit            [ [2,7],[4,7] ], :sector4, :room1   # top exit
                end

                set_current_room :room1
              end
  end

  it 'is created with a description block' do
    assert_equal  1, @sector.rooms.length
    assert        @sector.rooms.has_key?( :room1 )

    room  = @sector.rooms[:room1]
    assert_equal  '../sprites/tiles.png', room.instance_variable_get(:@tilesheet)
  end

  it 'returns the current room in the sector' do
    assert_equal  @sector.rooms[:room1], @sector.current_room
  end
end
