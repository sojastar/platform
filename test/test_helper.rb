require           'minitest/pride'

require_relative  '../lib/fsm_machine.rb'
require_relative  '../lib/fsm_state.rb'
require_relative  '../lib/room.rb'
require_relative  '../lib/sector.rb'

class GTK
  attr_accessor :args
  def initialize
    @args = Args.new
  end

  def read_file(filename)
    File.read(filename)
  end
end

class Args
  attr_accessor :outputs

  def initialize
    @outputs        = Outputs.new
    @render_targets = {}
  end

  def render_target(name)
    @render_targets[name] = Outputs.new unless @render_targets.keys.include? name
    @render_targets[name]
  end
end

class Outputs
  attr_accessor :width, :height,
                :sprites

  def initialize
    @width    = 1280
    @height   = 720
    @sprites  = []
    @lines    = []
    @borders  = []
    @solids   = []
    @labels   = []
  end
end

$gtk  = GTK.new
