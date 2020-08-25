class Camera

  # ---=== INITIALISATION : ===---
  def initialize(width,height,scale,offset_x,offset_y)
    set_frame   width, height
    set_scale   scale
    set_offset  offset_x, offset_y
  end

  def set_frame(width,height)
    @width        = width
    @height       = height
    @half_width   = width  >> 1
    @half_height  = height >> 1
  end

  def set_scale(scale)
    @scale        = scale
  end

  def set_offset(offset_x, offset_y)
    @offset_x     = offset_x
    @offset_y     = offset_y
  end


  # ---=== RENDER : ===---
  def render(room,player)
    source_x  = if    player.position[0] - @half_width <= 0          then 0
                elsif player.position[0] + @half_width >= room.width then room.width - @width
                else  player.position[0] - @half_width
                end

    source_y  = if    player.position[1] - @half_height <= 0            then 0
                elsif player.position[1] + @half_height >= room.height  then room.height - @height
                else  player.position[1] - @half_height
                end

    source_w  = @width
    source_h  = @height

    $gtk.args.render_target(:camera).width  @width
    $gtk.args.render_target(:camera).height @height
    $gtk.args.render_target << { x:         @offset_x,
                                 y:         @offset_y,
                                 w:         @width  * @scale,
                                 h:         @height * @scale,
                                 path:      room.render(args),
                                 source_x:  source_x,
                                 source_y:  source_y,
                                 source_w:  source_w,
                                 source_h:  source_h }
  end
end
