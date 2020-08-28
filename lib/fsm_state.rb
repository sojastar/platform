module FSM
  class State
    attr_reader :name, :events, :setup

    def initialize(name,&configuration_block)
      @name       = name

      @setup      = nil
      @action     = nil
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

    def define_action(&block)
      if block.nil? then
        raise "ERROR: define_action called withouth a block for state #{@name}"

      else
        @action = block

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
        return event[:next_state] if object.instance_exec(args, &event[:check]) 
      end

      object.instance_exec(args, &@action) unless @action.nil?

      return @name
    end
  end
end
