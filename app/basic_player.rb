class Player
  def self.spawn_basic_player_at(start_x,start_y,health)
    
    # ---=== ANIMATION : ===---
    frames  = { idle:         { file:   '/assets/sprites/hero_idle.png',
                                frames: [ [0,0], [1,0], [2,0], [3,0], [4,0], [5,0], [6,0] ],
                                mode:   :loop,
                                speed:  8,
                                flip_horizontally:  false,
                                flip_vertically:    false },
                walk:         { file:   '/assets/sprites/hero_walk.png',
                                frames: [ [0,0], [1,0], [2,0], [3,0] ],
                                mode:   :loop,
                                speed:  6,
                                flip_horizontally:  false,
                                flip_vertically:    false },
                jumping_up:   { file:   '/assets/sprites/hero_jump.png',
                                frames: [ [0,0], [1,0], [2,0], [3,0] ],
                                mode:   :once,
                                speed:  6,
                                flip_horizontally:  false,
                                flip_vertically:    false },
                jumping_down: { file:   '/assets/sprites/hero_jump.png',
                                frames: [ [4,0], [5,0], [6,0] ],
                                mode:   :once,
                                speed:  6,
                                flip_horizontally:  false,
                                flip_vertically:    false } }

    animation         = Animation.new 8, 8,     # width and height
                                      frames,   # frames
                                      :idle     # first animation


    # ---=== FINITE STATE MACHINE : ===---
    fsm     = FSM::new_machine(nil) do

                # 
                define_update do |args|
                  # --- Player input :
                  if    args.inputs.keyboard.key_held.right then  @dx =  1
                  elsif args.inputs.keyboard.key_held.left  then  @dx = -1
                  else                                            @dx =  0
                  end

                  # --- Gravity :
                  @dy  += GRAVITY
                end

                add_state(:idle) do
                  define_setup do
                    @animation.set_clip :idle
                    @dx = 0
                  end

                  add_event(next_state: :walking_left) do |args|
                    args.inputs.keyboard.key_held.left
                  end

                  add_event(next_state: :walking_right) do |args|
                    args.inputs.keyboard.key_held.right
                  end

                  add_event(next_state: :jumping_up) do |args|
                    args.inputs.keyboard.key_down.space
                  end
                end

                add_state(:walking_left) do
                  define_setup do
                    @animation.set_clip :walk
                    @facing_right = false
                  end

                  add_event(next_state: :idle) do |args|
                    args.inputs.keyboard.key_held.left == false
                  end

                  add_event(next_state: :walking_right) do |args|
                    args.inputs.keyboard.key_down.right
                  end

                  add_event(next_state: :jumping_up) do |args|
                    args.inputs.keyboard.key_down.space
                  end
                end

                add_state(:walking_right) do
                  define_setup do
                    @animation.set_clip :walk
                    @facing_right = true
                  end

                  add_event(next_state: :idle) do |args|
                    args.inputs.keyboard.key_held.right == false
                  end

                  add_event(next_state: :walking_left) do |args|
                    args.inputs.keyboard.key_down.left
                  end

                  add_event(next_state: :jumping_up) do |args|
                    args.inputs.keyboard.key_down.space
                  end
                end

                add_state(:jumping_up) do
                  define_setup do
                    @animation.set_clip :jumping_up
                    @dy   = 4
                  end

                  add_event(next_state: :jumping_down) do |args|
                    @dy <= 0.0
                  end
                end

                add_state(:jumping_down) do
                  define_setup do
                    @animation.set_clip :jumping_down
                  end

                  add_event(next_state: :idle) do |args|
                    @dy == 0
                  end
                end

                set_initial_state :idle
              end


    # ---=== INSTANCIATION : ===---
    Player.new  animation,
                fsm,
                start_x,
                start_y,
                health

  end
end
