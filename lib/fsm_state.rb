module FSM
  class State
    attr_reader :name, :events, :setup

    def initialize(name,&configuration_block)
      @name       = name

      @setup      = nil
      @update     = nil
      @exit       = nil
      @events     = []

      if configuration_block.nil? then
        raise "ERROR: no configuration block given for new state #{@name}"

      else
        instance_eval &configuration_block

      end
    end

    def define_setup(&block)
      if block.nil? then
        raise "ERROR: define_setup called withouth a block for state #{@name}"

      else
        @setup  = block

      end
    end

    def define_update(&block)
      if block.nil? then
        raise "ERROR: define_update called withouth a block for state #{@name}"

      else
        @update = block

      end
    end

    def define_exit(&block)
      if block.nil? then
        raise "ERROR: define_update called withouth a block for state #{@name}"

      else
        @exit = block

      end
    end

    def add_event(next_state:,&block)
      if block.nil? then
        raise "add_event called withouth a block for state #{@name}"

      else
        @events << {  check:  block,
                      next_state: next_state }

      end
    end

    def update(object,args)
      @events.each do |event|
        if object.instance_exec(args, &event[:check]) then
          object.instance_exec(args, &@exit) unless @exit.nil?
          return event[:next_state] 
        end
      end

      object.instance_exec(args, &@update) unless @update.nil?

      return @name
    end
  end
end
