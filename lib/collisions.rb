module Collisions
  def self.resolve_collisions_with_rects(position,size,velocity,rects)
    # First round of collision testing that will teel us ...
    # ... the distance of each collision :
    collisions  = []
    ray_end     = [ position[0] + velocity[0],
                    position[1] + velocity[1] ]
    rects.each do |rect|
      #ray_end         = [ position[0] + velocity[0],
      #                    position[1] + velocity[1] ]
      collision_zone  = [ rect[0] - size[0] / 2,
                          rect[1] - size[1] / 2, 
                          rect[2] + size[0],
                          rect[3] + size[1] ]
      intersection    = ray_rect_intersection position, ray_end, collision_zone
  
      collisions << { rect: rect, distance: intersection[:distance] } unless intersection.nil?
    end
  
    # Second round of collision testing oredered by distance ...
    # ... from closest to furthest :
    new_velocity  = [ velocity[0],
                      velocity[1] ]
    collisions.sort_by { |collision| collision[:distance] }.each.with_index do |collision,i|
      ray_end         = [ position[0] + new_velocity[0],
                          position[1] + new_velocity[1] ]
      collision_zone  = [ collision[:rect][0] - size[0] / 2,
                          collision[:rect][1] - size[1] / 2, 
                          collision[:rect][2] + size[0],
                          collision[:rect][3] + size[1] ]
      intersection    = ray_rect_intersection position, ray_end, collision_zone
  
      unless intersection.nil? then
        new_velocity[0] += intersection[:normal][0] * new_velocity[0].abs * ( 1 - intersection[:distance] )
        new_velocity[1] += intersection[:normal][1] * new_velocity[1].abs * ( 1 - intersection[:distance] )
      end
    end
  
    new_velocity
  end
  
  def self.ray_rect_intersection(ray_origin,ray_end,rect)
    x_intersection1, x_intersection2  = ray_rect_intersections_x( ray_origin,
                                                                  ray_end, 
                                                                  rect ).sort
    y_intersection1, y_intersection2  = ray_rect_intersections_y( ray_origin,
                                                                  ray_end, 
                                                                  rect ).sort
    biggest_smallest                  = [ x_intersection1, y_intersection1 ].max
  
    if  x_intersection1 < y_intersection2 &&
        y_intersection1 < x_intersection2 &&
        (0.0..1.0) === biggest_smallest then
  
      intersection  = [ ray_origin[0] + ( ray_end[0] - ray_origin[0] ) * biggest_smallest, 
                        ray_origin[1] + ( ray_end[1] - ray_origin[1] ) * biggest_smallest ]
  
      normal  = if    x_intersection1 > y_intersection1 then
                  ray_end[0] - ray_origin[0] < 0 ? [ 1.0, 0.0 ] : [ -1.0,  0.0 ]
                elsif x_intersection1 < y_intersection1 then
                  ray_end[1] - ray_origin[1] < 0 ? [ 0.0, 1.0 ] : [  0.0, -1.0 ]
                else
                  [ 0.0, 0.0 ]
                end
  
      { position: intersection, normal: normal, distance: biggest_smallest.abs }
  
    else
      nil
  
    end
  end
  
  def self.ray_rect_intersections_x(ray_origin,ray_end,rect)
    ray_delta_x   = ray_end[0] - ray_origin[0]
  
    [ ( rect[0]           - ray_origin[0] ) / ray_delta_x.to_f,
      ( rect[0] + rect[2] - ray_origin[0] ) / ray_delta_x.to_f ]
  end
  
  def self.ray_rect_intersections_y(ray_origin,ray_end,rect)
    ray_delta_y   = ray_end[1] - ray_origin[1]
  
    [ ( rect[1]           - ray_origin[1] ) / ray_delta_y.to_f,
      ( rect[1] + rect[3] - ray_origin[1] ) / ray_delta_y.to_f ]
  end
end 
