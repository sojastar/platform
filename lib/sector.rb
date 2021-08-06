module Platformer
  class Sector
    attr_reader :tileset,
                :rooms

    # ---=== INITIALISATION : ===---
    def initialize(filename)
      json_data = $gtk.parse_json_file filename

      # We assume there is only one tileset per sector.
      @tileset      = Platformer::TileSet.new json_data['defs']['tilesets'].first

      @current_room = 0
      @rooms        = json_data['levels'].map do |level|
                        Platformer::Room.new level
                      end
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
end
