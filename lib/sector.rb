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

      @player       = nil
    end

    def current_room
      @rooms[@current_room]
    end


    # ---=== UPDATE : ===---
    def update(args,player)
      @rooms[@current_room].update(args)
    end


    # ---=== RENDER : ===---
    def render(args,scale)
      @rooms[@current_room].render(args, scale)
    end


    # ---=== SERIALIZATION : ===---
    def serialize
      { room_count: @rooms.length, rooms: @rooms.keys }
    end

    def inspect() serialize.to_s  end
    def to_s()    serialize.to_s  end 
  end
end
