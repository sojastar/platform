class Zombie
  def self.spawn_at(spawn_x,spawn_y,health,path,speed)
    # ---=== ANIMATION : ===---
    frames  = { walk:         { file:               '/assets/sprites/zombie_walk.png',
                                #frames:             8.times.map { |frame| [ 0, frame ] },
                                frames:             [ [0,0], [1,0], [2,0], [3,0], [4,0], [5,0], [6,0], [7,0] ],
                                mode:               :loop,
                                speed:              12,
                                flip_horizontally:  false,
                                flip_vertically:    false } }
  
    animation         = Animation.new 8, 8,     # width and height
                                      frames,   # frames
                                      :walk     # first animation
  
  
    # ---=== FINITE STATE MACHINE : ===---
    fsm     = FSM::new_machine(nil) do
  
                define_update do |args|
                end
  
                add_state(:walking_left) do
                  define_setup do
                    @animation.set_clip :walk
                  end

                  add_event(next_state: :walking_right) do |args|
                    @facing_right == true
                  end
                end
  
                add_state(:walking_right) do
                  define_setup do
                    @animation.set_clip :walk
                  end
  
                  add_event(next_state: :walking_left) do |args|
                    @facing_right == false
                  end
                end
  
                set_initial_state :walking_left
              end
  
  
    # ---=== INSTANCIATION : ===---
    Platformer::Monster.new animation,
                            fsm,
                            spawn_x - 4, spawn_y - 4,
                            health,
                            path,
                            speed
  end
end
