module Platformer
  class Path
    attr_reader :type, :subpaths, :index

    # ---=== INITIALIZATION : ===---
    def initialize(nodes,type,pause)
      @type       = type

      single_path   = build_path nodes
      reverse_path  = build_path nodes.reverse

      @subpaths = case type
                  when :once
                    single_path << { type: :end }

                  when :loop
                    if pause > 0 then single_path << { type: :pause, duration: pause }
                    else              single_path
                    end

                  when :pingpong
                    if pause > 0 then single_path +
                                      [ { type: :pause, duration: pause } ] +
                                      reverse_path +
                                      [ { type: :pause, duration: pause } ]
                    else              single_path + reverse_path
                    end
                  end

      @index      = 0
    end

    def build_path(nodes)
      nodes.each_cons(2).map do |p1,p2|
        length  = Math::sqrt( ( p2[0] - p1[0] ) ** 2 + ( p2[1] - p1[1] ) ** 2 )
        udx     = ( p2[0] - p1[0] ) / length
        udy     = ( p2[1] - p1[1] ) / length

        { type: :movement, start: p1, end: p2, ud: [ udx, udy ] }
      end
    end

    def reset
      @index = 0
    end


    # ---=== SUBPATHS : ===---
    def next_step_index
      if @type == :once then  next_index  = @index < @subpaths.length - 1 ? @index + 1 : @index
      else                    next_index  = ( @index + 1 ) % @subpaths.length
      end

      next_index
    end

    def move_to_next_step
      @index  = next_step_index
    end

    def current_step
      @subpaths[@index]
    end

    def direction
      @subpaths[@index][:ud] if @subpaths[@index][:type] == :movement
    end

    def did_reach_current_subpath_end(x,y,precision)
      ( @subpaths[@index][:end][0] - x ).abs < precision &&
      ( @subpaths[@index][:end][1] - y ).abs < precision
    end

    def did_reach_next_movement(x,y,precision)
      did_reach_current_subpath_end(x, y, precision) &&
      @subpaths[next_step_index][:type] == :movement
    end


    # ---=== PAUSE : ===---
    def start_pause
      @pause_start  = $gtk.args.state.tick_count
    end

    def is_pause_finished
      $gtk.args.state.tick_count - @pause_start > @subpaths[@index][:duration]
    end

    def did_reach_pause(x,y,precision)
      did_reach_current_subpath_end(x, y, precision) &&
      @subpaths[next_step_index][:type] == :pause
    end


    # ---=== END : ===---
    def did_reach_end(x,y,precision)
      did_reach_current_subpath_end(x, y, precision) &&
      @subpaths[next_step_index][:type] == :end
    end


    # ---=== SERIALIZATION : ===---
    def serialize
      { type: @type, subpaths: @subpaths, index: @index }
    end

    def inspect() serialize.to_s end
    alias to_s inspect
  end
end
