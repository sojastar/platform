class Player
  def self.spawn_basic_player_at(start_x,start_y,health)
    
    # ---=== ANIMATION : ===---
    frames  = { idle: { file:   '/sprites/human_idle.png',
                        frames: [ [0,0], [1,0] ],
                        mode:   :loop,
                        speed:  12,
                        flip_horizontally:  false,
                        flip_vertically:    false },
                walk: { file:   '/sprites/human_walk.png',
                        frames: [ [0,0], [1,0], [2,0], [3,0], [4,0], [5,0], [6,0], [7,0] ],
                        mode:   :loop,
                        speed:  6,
                        flip_horizontally:  false,
                        flip_vertically:    false } }

    animation         = Animation.new 8, 8,     # width and height
                                      frames,   # frames
                                      :idle     # first animation


    # ---=== FINITE STATE MACHINE : ===---
    fsm     = FSM::new_machine(nil) do
                add_state(:idle) do
                  define_setup do
                    @animation.set_clip :idle
                  end

                  add_event(next_state: :walking_left) do |args|
                    args.inputs.keyboard.key_held.left
                  end

                  add_event(next_state: :walking_right) do |args|
                    args.inputs.keyboard.key_held.right
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
