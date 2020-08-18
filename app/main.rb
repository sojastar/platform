require 'lib/fsm_machine.rb'
require 'lib/fsm_state.rb'
require 'lib/animation.rb'
require 'lib/keymap.rb'





# ---=== CONSTANTS : ===---





# ---=== SETUP : ===---
def setup(args)


  args.state.setup_done = true
end





# ---=== MAIN LOOP : ===---
def tick(args)

  # --- 1. Setup :
  setup(args) unless args.state.setup_done


  # --- 2. Main Loop :
end





# ---=== UTILITIES : ===---
