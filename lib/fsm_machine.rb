module FSM
  class Machine
    attr_reader :parent, :states, :current_state

    # ---=== INITIALIZATION : ===---
    def initialize(parent,&configuation_block)
      @parent         = parent

      @states         = {}
      @initial_state  = nil
      @current_state  = nil

      @update         = nil

      instance_eval &configuation_block
    end

    def set_parent(new_parent)
      @parent         = new_parent
    end

    def start
      set_current_state @initial_state
    end


    # ---=== STATES : ===---
    def add_state(name,&configuration_block)
      @states[name]   = State.new name, &configuration_block
    end

    def set_initial_state(state_name)
      @initial_state  = state_name
    end

    def set_current_state(state_name)
      if @states.keys.include? state_name then
        @parent.instance_eval &@states[state_name].setup
        @current_state  = state_name

      else
        raise "!!! state :#{state_name} does not exist for object #{@parent}"

      end
    end


    # ---=== UPDATE : ===---
    def define_update(&update_block)
      if update_block.nil? then
        raise "ERROR: define_update called withouth a block for new machine"

      else
        @update = update_block

      end
    end

    def update(args)
      update = @states[@current_state].update @parent, args

      if update[:change] then
        if @states.keys.include? update[:state] then
          set_current_state update[:state]

        else
          raise "state :#{update[:state]} does not exist for object #{@parent}"

        end
      end

      @parent.instance_exec(args, &@update) unless @update.nil?
    end
  end


  # ---=== FACTORY : ===---
  def self.new_machine(parent,&configuration_block)
    Machine.new(parent, &configuration_block)
  end


  # ---=== SERIALIZATION : ===---
  def serialize
    { states: @states.keys }
  end

  def inspect
    serialize.to_s
  end

  def to_s
    serialize.to_s
  end
end
