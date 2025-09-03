#import "Random";
#import "Math";

#scope_module

point_on_sphere :: () -> Vector3 {
  x : float32 = random_get_within_range(-1.0, 1.0);
  y : float32 = random_get_within_range(-1.0, 1.0);
  z : float32 = random_get_within_range(-1.0, 1.0);

  return normalize(Vector3.{x, y, z});
}

point_within_sphere :: () -> Vector3 {
  
}

point_on_hemisphere :: () -> Vector3 {

}

point_within_hemisphere :: () -> Vector3 {
  
}

closest_point_on_line :: () -> Vector3 {

}

closest_point_on_plane :: () -> Vector3 {

}

closest_point_on_sphere :: () -> Vector3 {

}

closest_point_on_cube :: () -> Vector3{

}

