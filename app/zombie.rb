class Zombie
  def self.spawn_at(spawn,size,health,path,speed)
    # ---=== ANIMATION : ===---
    frames  = { walk:         { file:               '/assets/sprites/zombie_walk.png',
                                frames:             [ [0,0], [1,0], [2,0], [3,0], [4,0], [5,0], [6,0], [7,0] ],
                                mode:               :loop,
                                speed:              12,
                                flip_horizontally:  false,
                                flip_vertically:    false } }
  
    animation         = Animation.new size[0], size[1], # width and height
                                      frames,           # frames
                                      :walk             # first animation
  
  
    # ---=== FINITE STATE MACHINE : ===---
    fsm     = FSM::new_machine(nil) do
  
                define_update do |args|
                  # They just walk, so all behaviours are ...
                  # ... defined in the walking states.
                end
  
                add_state(:walking_left) do
                  define_setup do
                    go_to_next_path_step
                    @animation.set_clip :walk
                    @facing_right = false
                    @dx, @dy      = -speed, 0.0
                  end

                  add_event(next_state: :walking_right) do |args|
                    ( @x - next_path_point.x ).abs < speed
                  end
                end
  
                add_state(:walking_right) do
                  define_setup do
                    go_to_next_path_step
                    @animation.set_clip :walk
                    @facing_right = true
                    @dx, @dy      = speed, 0.0
                  end
  
                  add_event(next_state: :walking_left) do |args|
                    ( @x - next_path_point.x ).abs < speed
                  end
                end
  
                set_initial_state :walking_left
              end
  
  
    # ---=== INSTANCIATION : ===---
    Platformer::Monster.new animation,
                            fsm,
                            size,
                            spawn[0] + size[0] / 2, spawn[1] - size[1] / 2,
                            health,
                            path,
                            speed
  end
end
