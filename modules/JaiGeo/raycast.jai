#import "Math";

#scope_module
intersect_ray_aabb :: (
  origin_x : float,
  origin_y : float,
  origin_z : float,
  dir_x : float,
  dir_y : float,
  dir_z : float, 
  min_x : float,
  min_y : float,
  min_z : float, 
  max_x : float,
  max_y : float,
  max_z : float
) -> (
  intersects : bool,
  intersection_point : Vector3
) {
  // Store the inverse directions
  inverse_direction_x := 1.0 / dir_x;
  inverse_direction_y := 1.0 / dir_y;
  inverse_direction_z := 1.0 / dir_z;

  // Compute the Near and Far Planes
  near : float;
  far : float;
  
  if (inverse_direction_x >= 0.0) {
    near = (min_x - origin_x) * inverse_direction_x;
    far  = (max_x - origin_x) * inverse_direction_x;
  } else {
    near = (max_x - origin_x) * inverse_direction_x;
    far  = (min_x - origin_x) * inverse_direction_x;
  }

  // Compute Y Min Max
  tymin : float;
  tymax : float;
  
  if inverse_direction_y >= 0.0 {
    tymin = (min_y - origin_y) * inverse_direction_y;
    tymax = (max_y - origin_y) * inverse_direction_y;
  } else {
    tymin = (max_y - origin_y) * inverse_direction_y;
    tymax = (min_y - origin_y) * inverse_direction_y;
  }

  // Intersection Tests near 
  if (!(near > tymax) && !(tymin > far)) {
    tzmin : float;
    tzmax : float;
    if inverse_direction_z >= 0.0 {
      tzmin = (min_z - origin_z) * inverse_direction_z;
      tzmax = (max_z - origin_z) * inverse_direction_z;
    } else {
      tzmin = (max_z - origin_z) * inverse_direction_z;
      tzmax = (min_z - origin_z) * inverse_direction_z;
    }
    
    if (!(near > tzmax) && !(tzmin > far)) {
      near = ifx (!(tymin > near) && !isnan(near)) then near else tymin;
      far = ifx (!(tymax < far) && !isnan(far)) then far else tymax;
      near = ifx (tzmin > near) then tzmin else near;
      far = ifx (tzmax < far) then tzmax else far;
      // Check if this intersection test is successful
      // print("near:% far:%\n", near, far);
      if (near < far && far >= 0.0) {
        intersection_point : Vector3 = .{0, 0, 0};
        // We have intersected something, so we are going to calculate the intersection point in 3D space.
        intersection_point.x = dir_x * near + origin_x;
        intersection_point.y = dir_y * near + origin_y;
        intersection_point.z = dir_z * near + origin_z;
        // Return our hit result
        return true, intersection_point;
      }
    }
  }
  return false, .{};
}

// This is a wrapper for the intersectRayAabF function and allows you to call the method with vectors instead of floats.
intersect_ray_aabb :: (
  origin : Vector3,
  dir : Vector3,
  min : Vector3,
  max : Vector3,
  epsilon : float = 0.000001
) -> (
  intersects : bool,
  intersection_point : Vector3
) {
  // Call the base method.
  intersects, intersection_point := intersect_ray_aabb(
    origin.x, origin.y, origin.z,
    dir.x, dir.y, dir.z,
    min.x - epsilon, min.y - epsilon, min.z - epsilon,
    max.x + epsilon, max.y + epsilon, max.z + epsilon
  );
  // Return the values from the base method.
  return intersects, intersection_point;
}