class Player < Actor

  # ---=== INITIALISATION : ===---
  def initialize(animation,fsm,start_x,start_y,health)
    super(animation,fsm,start_x,start_y)
    
    @health = health
  end
  
  # ---=== UPDATE : ===---
  def update(args,sector)
    @machine.update(args)
    @animation.update

    @x += 1 if args.inputs.keyboard.key_held.right
    @x -= 1 if args.inputs.keyboard.key_held.left
  end


  # ---=== RENDER : ===---
  def render(args)
    @animation.frame_at @x, @y, !@facing_right
  end


  # ---=== SERIALIZATION : ===---
  def serialize
    { x: @x, y:@y }
  end

  def inspect() serialize.to_s  end
  def to_s()    serialize.to_s  end 
end
