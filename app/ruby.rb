class Ruby
  def self.place_at(place,size,single)
    # ---=== ANIMATION : ===---
    frames    = { idle: { file:               '/assets/sprites/ruby.png',
                          frames:             [ [0,0], [0,0], [0,0], [0,0], [0,0], [0,0], [0,0], [0,0], [1,0], [2,0], [3,0], [4,0], [5,0], [6,0], [7,0] ],
                          mode:               :loop,
                          speed:              4,
                          flip_horizontally:  false,
                          flip_vertically:    false } }
  
    animation = Animation.new size[0], size[1], # width and height
                              frames,           # frames
                              :walk             # first animation
  
  
    # ---=== FINITE STATE MACHINE : ===---
    fsm     = FSM::new_machine(nil) do
  
                define_update do |args|
                  # They just stand there, so all behaviours are ...
                  # ... defined in the idle state.
                end
  
                add_state(:idle) do
                  define_setup do
                    @animation.set_clip :idle
                  end
                end
  
                set_initial_state :idle
              end
  
  
    # ---=== INSTANCIATION : ===---
    Platformer::Item.new  :ruby,        # type
                          single,
                          animation,
                          fsm,
                          size,
                          [ place[0] + size[0] / 2, place[1] - size[1] / 2 ]
  end
end

