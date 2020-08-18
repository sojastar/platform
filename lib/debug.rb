module Debug
  # ---=== DEBUG MODE PARSING: ===---
  def self.parse_debug_arg(argv)
    flags = {}
    argv.split[1..-1].each do |arg|
      flag, value = arg.split('=')
      flags[flag] = value
    end

    flags
  end


  # ---=== GRAPHIC HINTS : ===---
  def self.draw_cross(x,y,color)
    $gtk.args.render_target(:display).lines << [ x - 1, y - 1, x + 2, y + 2 ] + color
    $gtk.args.render_target(:display).lines << [ x - 1, y + 1, x + 2, y - 2 ] + color
  end

  def self.draw_box(bounds,color)
    $gtk.args.render_target(:display).borders << bounds + color
  end
end
