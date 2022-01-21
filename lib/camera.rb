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
  def render(args,room,player)
    source_x  = if    player.x - @half_width <= 0                 then 0
                elsif player.x + @half_width >= room.pixel_width  then room.pixel_width - @width
                else  player.x - @half_width
                end

    source_y  = if    player.y - @half_height <= 0                  then 0
                elsif player.y + @half_height >= room.pixel_height  then room.pixel_height - @height
                else  player.y - @half_height
                end

    source_w  = @width
    source_h  = @height

    args.render_target(:camera).width   @width
    args.render_target(:camera).height  @height
    args.render_target(:camera).sprites <<  { x:         @offset_x,
                                              y:         @offset_y,
                                              w:         @scale * @width,
                                              h:         @scale * @height,
                                              path:      room.render(args, player),
                                              source_x:  source_x,
                                              source_y:  source_y,
                                              source_w:  source_w,
                                              source_h:  source_h }
  end


  # ---=== SERIALIZATION : ===---
  def serialize
    { width: @width, height: @height, scale: @scale, offset_x: @offset_x, offset_y: @offset_y }
  end

  def inspect() serialize.to_s  end
  def to_s()    serialize.to_s  end 
end
