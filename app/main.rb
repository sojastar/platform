# ---=== 1. REQUIRES : ===----

# --- 1.1. Engine :
require 'lib/constants.rb'
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
require 'lib/monster.rb'

# --- 1.2. Game Specific :
require 'app/basic_player.rb'
require 'app/zombie.rb'





# ---=== 2. CONSTANTS : ===---
SCALE = 5





# ---=== 3. SETUP : ===---
def setup(args)
  args.state.sector     = Platformer::Sector.new 'assets/sectors/sector1.ldtk'

  args.state.player     = Player::spawn_basic_player_at args.state.sector.current_room.start_x,
                                                        args.state.sector.current_room.start_y,
                                                        3

  args.state.debug      = false

  args.state.setup_done = true
end





# ---=== 4. MAIN LOOP : ===---
def tick(args)

  # --- 4.1. Setup :
  setup(args) unless args.state.setup_done


  # --- 4.2. Main Loop :
  args.state.sector.update args, args.state.player


  # --- 4.3. Render :
  args.outputs.background_color = [0, 0, 0]

  args.state.sector.render  args,
                            args.state.player,
                            SCALE
end





# ---=== UTILITIES : ===---
