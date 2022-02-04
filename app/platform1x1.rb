class Platform1x1
  def self.spawn_at(spawn,size,path,speed)
    # ---=== ANIMATION : ===---
    frames    = { move: { file:               '/assets/sprites/platform.png',
                          frames:             [ [0,0] ],
                          mode:               :once,
                          speed:              12,
                          flip_horizontally:  false,
                          flip_vertically:    false } }
  
    animation = Animation.new size[0], size[1], # width and height
                              frames,           # frames
                              :move             # first animation
  
  
    # ---=== FINITE STATE MACHINE : ===---
    fsm     = FSM::new_machine(nil) do
  
                define_update do |args|
                  # They just move, so all behaviours are ...
                  # ... defined in the moving state.
                end
  
                add_state(:move) do
                  define_setup do
                    @animation.set_clip :move
                    udx, udy  = @path.direction
                    @dx, @dy  = speed * udx, speed * udy
                  end

                  define_exit do
                    @path.move_to_next_step
                  end

                  add_event(next_state: :move) do |args|
                    @path.did_reach_next_movement @x, @y, speed
                  end

                  add_event(next_state: :pause) do |args|
                    @path.did_reach_pause @x, @y, speed
                  end

                  add_event(next_state: :finished) do |args|
                    @path.did_reach_end @x, @y, speed
                  end
                end

                add_state(:pause) do
                  define_setup do
                    @animation.set_clip :move
                    @dx, @dy = 0, 0
                    @path.start_pause
                  end

                  define_exit do
                    @path.move_to_next_step
                  end

                  add_event(next_state: :move) do |args|
                    @path.is_pause_finished
                  end
                end

                add_state(:finished) do
                  define_setup do
                    @animation.set_clip :move
                    @dx, @dy = 0, 0
                  end
                end

                set_initial_state :move
              end
  
  
    # ---=== INSTANCIATION : ===---
    Platformer::Platform.new  animation,
                              fsm,
                              size,
                              [ spawn[0] + size[0] / 2, spawn[1] - size[1] / 2 ],
                              path
  end
end
