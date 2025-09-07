Rect :: struct {
  x : int;
  y : int;
  width : int;
  height : int;
  file_path : string;
}

// Performs a lexicographic compare on (rect short side, rect long side).
// @return -1 if the smaller side of a is shorter than the smaller side of b, 1 if the other way around.
//   If they are equal, the larger side length is used as a tie-breaker.
//   If the rectangles are of same size, returns 0.
compareRectShortSide :: (a : *Rect, b : *Rect) -> int {
 smallerSideA := min(a.width, a.height);
 smallerSideB := min(b.width, b.height);
}

// Performs a lexicographic compare on (x, y, width, height).
nodeSortCmp :: (a : *Rect, b : *Rect) -> int {

}

// Returns true if a is contained in b.
is_contained_in :: (a : *Rect, b : *Rect) -> bool {
	return a.x >= b.x && a.y >= b.y && a.x+a.width <= b.x+b.width && a.y+a.height <= b.y+b.height;
}

clone_rect :: (to_clone : *Rect) -> *Rect {
  out := New(Rect);
  out.x = to_clone.x;
  out.y = to_clone.y;
  out.height = to_clone.height;
  out.width = to_clone.width;
  return out;
}