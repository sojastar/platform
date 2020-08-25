class Player < Actor

  # ---=== INITIALISATION : ===---
  def initialize(animation,fsm,start_x,start_y,health)

  end
  
  # ---=== UPDATE : ===---
  def update(args)
    @x += 1 if args.inputs.keyboard.key_held.right
    @x -= 1 if args.inputs.keyboard.key_held.left
    @y += 1 if args.inputs.keyboard.key_held.up
    @y -= 1 if args.inputs.keyboard.key_held.down
  end


  # ---=== RENDER : ===---
  def render(args)

  end
end
