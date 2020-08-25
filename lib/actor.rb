class Actor
  attr_sprite

  # ---=== INITIALISATION : ===---
  def initialize(animation,fsm,start_x,start_y)
    @animation  = animation
    
    @machine    = machine
    @machine.set_parent self
    @machine.start

    @x          = start_x
    @y          = start_y
  end


  # ---=== UPDATE : ===---
  def update(args)
    @machine.update(args) unless @machine.nil?
    @animation.update     unless @animation.nil?
  end
end
