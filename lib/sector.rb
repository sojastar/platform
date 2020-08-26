class Sector
  attr_reader :rooms

  # ---=== INITIALISATION : ===---
  def initialize
    @rooms  = {}
  end

  def self.create_sector(&block)
    if block.nil? then
      raise "ERROR: trying to create new sector but no block given."

    else
      new_sector = Sector.new
      new_sector.instance_eval &block

      raise "ERROR: newly created sector doesn't have any rooms. Did you forget to add some?"         if      new_sector.rooms.empty?
      raise "ERROR: newly created sector doesn't have a current room set. Did you forget to set one?" unless  new_sector.instance_variable_defined?(:@current_room)

      new_sector
    end
  end

  def add_room(name,&room_block)
    @rooms[name]  = Room::create_room &room_block
  end

  def set_current_room(room)
    @current_room = room
  end

  def current_room
    @rooms[@current_room]
  end


  # ---=== UPDATE : ===---
  def update(args,player)
    @rooms[@current_room].update(args,player)
  end


  # ---=== RENDER : ===---
  def render(args)
    @rooms[@current_room].render(args)
  end


  # ---=== SERIALIZATION : ===---
  def serialize
    { room_count: @rooms.length, rooms: @rooms.keys }
  end

  def inspect() serialize.to_s  end
  def to_s()    serialize.to_s  end 
end
