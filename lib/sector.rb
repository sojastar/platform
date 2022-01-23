module Platformer
  class Sector
    attr_reader   :tileset,
                  :rooms

    attr_accessor :player

    # ---=== INITIALISATION : ===---
    def initialize(filename)
      json_data = $gtk.parse_json_file filename

      # We assume there is only one tileset per sector.
      @tileset      = Platformer::TileSet.new json_data['defs']['tilesets'].first

      @current_room = :room0  # !!! the first room is always Room0 !!!
      @rooms        = json_data['levels'].map do |level|
                        [ level['identifier'].downcase.to_sym,
                          Platformer::Room.new(self, level) ]
                      end
                      .to_h
      
      # Have to account for the LDtk vs DragonRuby vertical orientation :
      @rooms.each_pair do |name,room|
        room.exits.each do |exit_data|
          exit_data[:destination_y] = @rooms[exit_data[:destination_name]].pixel_height - exit_data[:destination_y]
        end
      end

      @player       = nil
    end

    def current_room
      @rooms[@current_room]
    end


    # ---=== UPDATE : ===---
    def update(args,player)
      @rooms[@current_room].update(args,player)
    end

    def move_to_room(name,player,x,y)
      @current_room = name

      player.add_collected_to_owned
      player.x = x
      player.y = y
      @rooms[@current_room].last_entry_point  = [ x, y, player.facing_right ]
      @rooms[@current_room].reset(player)
    end


    # ---=== RENDER : ===---
    def render(args,player,scale)
      @rooms[@current_room].render(args, player, scale)
    end


    # ---=== SERIALIZATION : ===---
    def serialize
      { room_count: @rooms.length, rooms: @rooms.keys }
    end

    def inspect() serialize.to_s  end
    def to_s()    serialize.to_s  end 
  end
end
