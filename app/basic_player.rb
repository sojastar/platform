module Player
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

                define_update do |args|
                  if @mode == :play then                   
                    # --- Player input :
                    if    args.inputs.keyboard.key_held.right then
                      @dx           =  1
                      @facing_right = true
                    elsif args.inputs.keyboard.key_held.left  then
                      @dx           = -1
                      @facing_right = false
                    else
                      @dx =  0
                    end

                    # --- Gravity :
                    @dy  += Platformer::GRAVITY
                    @dy   = -Platformer::MAX_SPEED if @dy < -Platformer::MAX_SPEED

                    if args.inputs.keyboard.key_held.r then
                      @moves        = $gtk.parse_json_file 'assets/debug/reproduce.json'
                      @mode         = :replay 
                      @replay_head  = 0
                      @x, @y        = @moves[@replay_head]["position"]
                      @dx, @dy      = @moves[@replay_head]["velocity"]
                      @facing_right = @moves[@replay_head]["direction"]
                    end

                  elsif @mode == :replay then
                    if args.inputs.keyboard.key_down.n then
                      @replay_head += 1
                      puts "#{@replay_head} - #{@moves[@replay_head]}"
                    end

                    if args.inputs.keyboard.key_down.b then
                      @replay_head -= 1
                      puts "#{@replay_head} - #{@moves[@replay_head]}"
                    end

                    @replay_head = 0                 if @replay_head == @moves.length
                    @replay_head = @moves.length - 1 if @replay_head < 0

                    @x, @y        = @moves[@replay_head]["position"]
                    @dx, @dy      = @moves[@replay_head]["velocity"]
                    @facing_right = @moves[@replay_head]["direction"]
                  end
                  
                  if args.inputs.keyboard.key_held.p then
                    @mode = :record
                  end
                end

                add_state(:idle) do
                  define_setup do
                    @animation.set_clip :idle
                    @dx = 0
                  end

                  add_event(next_state: :jumping_up) do |args|
                    args.inputs.keyboard.key_down.space
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
    Platformer::Player.new  animation,
                            fsm,
                            start_x,
                            start_y,
                            health

  end
end
