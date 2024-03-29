require           'minitest/pride'
require           'json'

require_relative  '../lib/fsm_machine.rb'
require_relative  '../lib/fsm_state.rb'
require_relative  '../lib/tileset.rb'
require_relative  '../lib/room.rb'
require_relative  '../lib/sector.rb'
#require_relative  '../lib/utilities.rb'
require_relative  '../lib/path.rb'

class GTK
  attr_accessor :args
  def initialize
    @args = Args.new
  end

  def read_file(filename)
    File.read filename
  end

  def parse_json(json_string)
    JSON.parse json_string
  end

  def parse_json_file(filename)
    json_string = ""
    File.open(filename, 'r') { |file| json_string = file.read }
    JSON.parse json_string
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

class DummySector
  attr_reader :tileset

  def initialize(json_data)
    @tileset = Platformer::TileSet.new json_data['defs']['tilesets'].first
  end
end
