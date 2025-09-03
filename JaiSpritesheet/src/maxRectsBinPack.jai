#scope_file
MaxRectsBinPack :: struct {
  binWidth : int;
  binHeight : int;
  binAllowFlip : bool = false;
  newFreeRectanglesLastSize : u32;
  newFreeRectangles : [..]*Rect;
	usedRectangles : [..]*Rect;
	freeRectangles : [..]*Rect;
}

DEFAULT_CHOICE_HEURISTIC :: FreeRectChoiceHeuristic.RECT_BEST_SHORT_SIDE_FIT;

// Computes the placement score for placing the given rectangle with the given method.
// @return rect - This struct identifies where the rectangle would be placed if it were placed.
// @return score1 - The primary placement score will be outputted here.
// @return score2 - The secondary placement score will be outputted here. This isu sed to break ties.
_score_rect :: (self : *MaxRectsBinPack, width : int, height : int, method : FreeRectChoiceHeuristic = DEFAULT_CHOICE_HEURISTIC) -> *Rect, int, int {
  new_node : *Rect;
  score_1 : int = S32_MAX;
  score_2 : int = S32_MAX;

  if method == {
    case .RECT_BEST_SHORT_SIDE_FIT;
      new_node, score_1, score_2 = _find_position_for_new_node_best_short_side_fit(self, width, height);
    case .RECT_BEST_LONG_SIDE_FIT;
      new_node, score_1, score_2 = _find_position_for_new_node_best_long_side_fit(width, height);
    case .RECT_BEST_AREA_FIT;
      new_node, score_1, score_2 = _find_position_for_new_node_best_area_fit(width, height);
    case .RECT_BOTTOM_LEFT_RULE;
      new_node, score_1, score_2 = _find_position_for_new_node_bottom_left(width, height);
    case .RECT_CONTACT_POINT_RULE;
      new_node, score_1 = _find_position_for_new_node_contact_point(width, height);
      score_1 = -score_1; // Reverse since we are minimizing, but for contact point score bigger is better.
  }

  // Cannot fit the current rectangle.
  if new_node == null || new_node.height == 0 {
    score_1 = S32_MAX;
    score_2 = S32_MAX;
  }

  return new_node, score_1, score_2;
}

// Places the given rectangle into the bin.
_place_rect :: (self : *MaxRectsBinPack, node : *Rect) {
  i := 0;
  while (i < self.freeRectangles.count) {
    if _split_free_node(self, self.freeRectangles[i], node) {
      self.freeRectangles[i] = self.freeRectangles[self.freeRectangles.count - 1];
			pop(*self.freeRectangles);
    } else {
      i += 1;
    }
  }

  _prune_free_list(self);

  array_add(*self.usedRectangles, node);
}

// Computes the placement score for the -Contact Point variant.
_contact_point_score_node :: (x : int, y : int, width : int, height : int) -> int {

}

_find_position_for_new_node_bottom_left :: (width : int, height : int) -> *Rect, int, int {

}

_find_position_for_new_node_best_short_side_fit :: (self : *MaxRectsBinPack, width : int, height : int) -> *Rect, int, int {
  best_node := New(Rect);
  best_short_side_fit : int = S32_MAX;
  best_long_side_fit : int = S32_MAX;

  for rect, index : self.freeRectangles {
    // Try to place the rectangle in upright (non-flipped) orientation.
    if rect.width >= width && rect.height >= height {
      leftover_horiz : int = abs(rect.width - width);
      leftover_vert : int = abs(rect.height - height);
      short_side_fit : int = min(leftover_horiz, leftover_vert);
      long_side_fit : int = max(leftover_horiz, leftover_vert);

      if (short_side_fit < best_short_side_fit || (short_side_fit == best_short_side_fit && long_side_fit < best_long_side_fit)) {
        best_node.x = rect.x;
        best_node.y = rect.y;
        best_node.width = width;
        best_node.height = height;
        best_short_side_fit = short_side_fit;
        best_long_side_fit = long_side_fit;
      }
    }

    if self.binAllowFlip && rect.width >= height && rect.height >= width {
      flipped_leftover_horiz : int = abs(rect.width - height);
      flipped_leftover_vert : int = abs(rect.height - width);
      flipped_short_side_fit : int = min(flipped_leftover_horiz, flipped_leftover_vert);
      flipped_long_side_fit : int = max(flipped_leftover_horiz, flipped_leftover_vert);

      if (flipped_short_side_fit < best_short_side_fit || (flipped_short_side_fit == best_short_side_fit && flipped_long_side_fit < best_long_side_fit)) {
        best_node.x = rect.x;
        best_node.y = rect.y;
        best_node.width = height;
        best_node.height = width;
        best_short_side_fit = flipped_short_side_fit;
        best_long_side_fit = flipped_long_side_fit;
      }
    }
  }

  return best_node, best_short_side_fit, best_long_side_fit;
}

_find_position_for_new_node_best_long_side_fit :: (width : int, height : int) -> *Rect, int, int {
  
}

_find_position_for_new_node_best_area_fit :: (width : int, height : int) -> *Rect, int, int {
  
}

_find_position_for_new_node_contact_point :: (width : int, height : int) -> *Rect, int {
  
}

// @return True if the free node was split.
_split_free_node :: (self : *MaxRectsBinPack, free_node : *Rect, used_node : *Rect) -> bool {
  // Test with SAT if the rectangles even intersect.
  if (used_node.x >= free_node.x + free_node.width) ||
     (used_node.x + used_node.width <= free_node.x) || 
     (used_node.y >= free_node.y + free_node.height) ||
     (used_node.y + used_node.height <= free_node.y) return false;
  
  // We add up to four new free rectangles to the free rectangles list below. None of these
	// four newly added free rectangles can overlap any other three, so keep a mark of them
	// to avoid testing them against each other.
  self.newFreeRectanglesLastSize = xx self.newFreeRectangles.count;

  if (used_node.x < free_node.x + free_node.width && used_node.x + used_node.width > free_node.x) {
    // New node at the top side of the used node.
    if (used_node.y > free_node.y && used_node.y < free_node.y + free_node.height) {
			new_node := clone_rect(free_node);
			new_node.height = used_node.y - new_node.y;
			_insert_new_free_rectangle(self, new_node);
		}

    // New node at the top side of the used node.
    if (used_node.y + used_node.height < free_node.y + free_node.height) {
			new_node := clone_rect(free_node);
			new_node.y = used_node.y + used_node.height;
			new_node.height = free_node.y + free_node.height - (used_node.y + used_node.height);
			_insert_new_free_rectangle(self, new_node);
		}
  }

  if (used_node.y < free_node.y + free_node.height && used_node.y + used_node.height > free_node.y) {
		// New node at the left side of the used node.
		if (used_node.x > free_node.x && used_node.x < free_node.x + free_node.width) {
			new_node := clone_rect(free_node);
			new_node.width = used_node.x - new_node.x;
			_insert_new_free_rectangle(self, new_node);
		}

		// New node at the right side of the used node.
		if (used_node.x + used_node.width < free_node.x + free_node.width) {
			new_node := clone_rect(free_node);
			new_node.x = used_node.x + used_node.width;
			new_node.width = free_node.x + free_node.width - (used_node.x + used_node.width);
			_insert_new_free_rectangle(self, new_node);
		}
	}

  return true;
}

_insert_new_free_rectangle :: (self: *MaxRectsBinPack, new_free_rect : *Rect) {
  assert(new_free_rect.width > 0, "new_free_rect.width must be greater than 0.");
  assert(new_free_rect.height > 0, "new_free_rect.height must be greater than 0.");

  i := 0;
  while (i < self.newFreeRectanglesLastSize ) {
    // Is this new free rectangle already accounted for?
    if is_contained_in(new_free_rect, self.newFreeRectangles[i]) return;

    // Does this new free rectangle obsolete a previous new free rectangle?
    if is_contained_in(self.newFreeRectangles[i], new_free_rect) {
      // Remove i'th new free rectangle, but do so by retaining the order
			// of the older vs newest free rectangles that we may still be placing
			// in calling function SplitFreeNode().
      self.newFreeRectanglesLastSize = self.newFreeRectanglesLastSize - 1;
			self.newFreeRectangles[i] = self.newFreeRectangles[self.newFreeRectanglesLastSize];
			self.newFreeRectangles[self.newFreeRectanglesLastSize] = self.newFreeRectangles[self.newFreeRectangles.count - 1];
			pop(*self.newFreeRectangles);
      print("i - % newFreeRectanglesLastSize - %\n", i, self.newFreeRectanglesLastSize);
    } else {
      i += 1;
    }
  }
  array_add(*self.newFreeRectangles, new_free_rect);
}

// Goes through the free rectangle list and removes any redundant entries.
_prune_free_list :: (self: *MaxRectsBinPack) {
  // Test all newly introduced free rectangles against old free rectangles.
  for rect, i : self.freeRectangles {
    j := 0;
    while (j < self.newFreeRectangles.count) {
      if is_contained_in(self.newFreeRectangles[j], self.freeRectangles[i]) {
        self.newFreeRectangles[j] = self.newFreeRectangles[self.newFreeRectangles.count - 1];
				pop(*self.newFreeRectangles);
      } else {
        // The old free rectangles can never be contained in any of the
				// new free rectangles (the new free rectangles keep shrinking
				// in size)
				assert(!is_contained_in(self.freeRectangles[i], self.newFreeRectangles[j]));

				j += 1;
      }
    }
  }

  // Merge new and old free rectangles to the group of old free rectangles.
  array_add(*self.freeRectangles, ..self.newFreeRectangles);
	array_reset(*self.newFreeRectangles);
}

#scope_export
FreeRectChoiceHeuristic :: enum u8{
  RECT_BEST_SHORT_SIDE_FIT  :: 0;
  RECT_BEST_LONG_SIDE_FIT   :: 1;
  RECT_BEST_AREA_FIT        :: 2;
  RECT_BOTTOM_LEFT_RULE     :: 3;
  RECT_CONTACT_POINT_RULE   :: 4;
}

MaxRectsBinPack :: struct {
  // Instantiates a bin of the given size.
  // @param allowFlip Specifies whether the packing algorithm is allowed to rotate the input rectangles by 90 degrees to consider a better placement.
  init :: (width : int, height : int, allow_flip : bool = false) -> *MaxRectsBinPack {
    maxRectsBinPack := New(MaxRectsBinPack);

    maxRectsBinPack.binWidth = width;
    maxRectsBinPack.binHeight = height;
    maxRectsBinPack.binAllowFlip = allow_flip;
    
    array_reset(*maxRectsBinPack.usedRectangles);

    n := New(Rect);
    n.x = 0;
    n.y = 0;
    n.width = width;
    n.height = height;

    array_reset(*maxRectsBinPack.freeRectangles);
    array_add(*maxRectsBinPack.freeRectangles, n);

    return maxRectsBinPack;
  }

  // Inserts a single rectangle into the bin, possibly rotated.
  insert :: (self : *MaxRectsBinPack, width : int, height : int, method : FreeRectChoiceHeuristic = DEFAULT_CHOICE_HEURISTIC) -> *Rect {
    // Return values
    new_node : *Rect;
    score_1 : int = S32_MAX;
    score_2 : int = S32_MAX;

    if method == {
      case .RECT_BEST_SHORT_SIDE_FIT;
        new_node, score_1, score_2 = _find_position_for_new_node_best_short_side_fit(self, width, height);
      case .RECT_BEST_LONG_SIDE_FIT;
        new_node, score_1, score_2 = _find_position_for_new_node_best_long_side_fit(width, height);
      case .RECT_BEST_AREA_FIT;
        new_node, score_1, score_2 = _find_position_for_new_node_best_area_fit(width, height);
      case .RECT_BOTTOM_LEFT_RULE;
        new_node, score_1, score_2 = _find_position_for_new_node_bottom_left(width, height);
      case .RECT_CONTACT_POINT_RULE;
        new_node, score_1 = _find_position_for_new_node_contact_point(width, height);
    }

    if new_node != null && new_node.height != 0 _place_rect(self, new_node);

    return new_node;
  }

  
  // Inserts the given list of rectangles in an offline/batch mode, possibly rotated.
	// @param rects The list of rectangles to insert. This vector will be destroyed in the process.
	// @param dst [out] This list will contain the packed rectangles. The indices will not correspond to that of rects.
	// @param method The rectangle placement rule to use when packing.
  insert :: (self : *MaxRectsBinPack, rects : [..] *Rect, dst : *[..] *Rect, method : FreeRectChoiceHeuristic = DEFAULT_CHOICE_HEURISTIC) {
    array_reset(dst);

    while (rects.count > 0) {
      best_score_1 : int = S32_MAX;
      best_score_2 : int = S32_MAX;
      best_rect_index : int = -1;
      best_node : *Rect;

      for rect, index : rects {
        new_node, score1, score2 := _score_rect(self, rect.width, rect.height, method);
        if (score1 < best_score_1 || (score1 == best_score_1 && score2 < best_score_2)) {
          best_score_1 = score1;
          best_score_2 = score2;
          best_node = new_node;
          best_rect_index = index;
        }
      }

      if best_rect_index == -1 {
        return;
      }

      _place_rect(self, best_node);
      array_add(dst, best_node);
      rects[best_rect_index] = rects[rects.count - 1];
      pop(*rects);
    }
  }

  // Computes the ratio of used surface area to the total bin area.
  occupancy :: (self : *MaxRectsBinPack) -> float {

  }
}