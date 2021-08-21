class Actor
  attr_sprite
  attr_accessor :dx, :dy,
                :machine,
                :animation

  # ---=== INITIALISATION : ===---
  def initialize(animation,fsm,start_x,start_y)
    @animation  = animation
    
    @machine    = fsm
    @machine.set_parent self
    @machine.start

    @x, @y      = start_x, start_y
    @dx, @dy    = 0, 0
  end


  # ---=== UPDATE : ===---
  def update(args)
    @machine.update(args) unless @machine.nil?
    @animation.update     unless @animation.nil?
  end
end
