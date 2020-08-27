require 'lib/fsm_machine.rb'
require 'lib/fsm_state.rb'
require 'lib/animation.rb'
require 'lib/keymap.rb'
require 'lib/room.rb'
require 'lib/sector.rb'
require 'lib/camera.rb'
require 'lib/actor.rb'
require 'lib/player.rb'
require 'app/basic_player.rb'





# ---=== CONSTANTS : ===---





# ---=== SETUP : ===---
def setup(args)
  args.state.sector     = Sector::create_sector do
                            add_room(:room1) do
                              set_tiles           '/sprites/tiles.png', 8, 8, 8
                              set_tilemaps        [ '/sprites/map16x8_tile_layer1.csv',
                                                    '/sprites/map16x8_tile_layer2.csv' ]
                              set_animation_speed 20
                              set_start_position  14, 2
                              add_exit            [ [ 2,7], [ 5,7] ], :sector1, :room16x16
                              add_exit            [ [15,3], [15,5] ], :sector1, :room8x8
                            end

                            set_current_room(:room1)
                          end

  width, height, scale   = 64, 64, 4
  offset_x              = ( args.grid.right - scale * width  ) / 2
  offset_y              = ( args.grid.top   - scale * height ) / 2
  args.state.camera     = Camera.new  width, height,      # viewframe size
                                      scale,              # scale
                                      offset_x, offset_y  # offset

  args.state.player     = Player::spawn_basic_player_at args.state.sector.current_room.start_x,
                                                        args.state.sector.current_room.start_y,
                                                        3

  args.state.setup_done = true
end





# ---=== MAIN LOOP : ===---
def tick(args)

  # --- 1. Setup :
  setup(args) unless args.state.setup_done


  # --- 2. Main Loop :
  args.state.player.update(args,args.state.sector.current_room)
  args.state.sector.update(args,args.state.player)


  # --- 3. Render :
  args.outputs.sprites << args.state.camera.render( args,
                                                    args.state.sector.current_room,
                                                    args.state.player )
end





# ---=== UTILITIES : ===---
