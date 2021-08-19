require 'lib/utilities.rb'
require 'lib/fsm_machine.rb'
require 'lib/fsm_state.rb'
require 'lib/animation.rb'
require 'lib/keymap.rb'
require 'lib/tileset.rb'
require 'lib/room.rb'
require 'lib/sector.rb'
require 'lib/actor.rb'
require 'lib/collisions.rb'
require 'lib/player.rb'
require 'app/basic_player.rb'





# ---=== CONSTANTS : ===---
SCALE = 6





# ---=== SETUP : ===---
def setup(args)
  args.state.sector     = Platformer::Sector.new 'assets/sectors/sector1.ldtk'

  puts args.state.sector.tileset.file

  #args.state.player     = Player::spawn_basic_player_at args.state.sector.current_room.start_x,
  #                                                      args.state.sector.current_room.start_y,
  #                                                      3

  args.state.setup_done = true
end





# ---=== MAIN LOOP : ===---
def tick(args)

  # --- 1. Setup :
  setup(args) unless args.state.setup_done


  # --- 2. Main Loop :
  #args.state.player.update(args,args.state.sector)
  args.state.sector.update(args,args.state.player)


  # --- 3. Render :
  args.outputs.background_color = [64, 0, 128]

  args.state.sector.render args, SCALE, true
end





# ---=== UTILITIES : ===---
