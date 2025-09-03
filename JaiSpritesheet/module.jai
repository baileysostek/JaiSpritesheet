#module_parameters(DIR : string = "./res");

#scope_file

#import "Basic";
#import "Hash_Table";
#import "Math";
#import "Random";

Simp    :: #import "Simp";
Texture :: Simp.Texture;

// Source Files
#load "src/maxRectsBinPack.jai";

#scope_export
#load "src/rect.jai";
texture_load_from_file :: (map: *Texture, filename: string, dst : *[..] *Rect, srgb:=false, build_mipmaps:=false) -> bool {

  test := MaxRectsBinPack.init(1024, 1024);

  rects : [..] *Rect;

  for 0..228 {
    c := New(Rect);
    c.x = 0;
    c.y = 0;
    c.width = xx random_get_within_range(8, 128);
    c.height = xx random_get_within_range(8, 128);
    array_add(*rects, c);
  }

  MaxRectsBinPack.insert(test, rects, dst);

  // c := New(Rect);
  // c.x = 0;
  // c.y = 0;
  // c.width = 15;
  // c.height = 11;
  // print("c-%\n", c.*);
  // print("Modified C\n");

  // d := clone_rect(c);
  // d.x = 100;
  // print("c-%\n", c.*);
  // print("d-%\n", d.*);

  return Simp.texture_load_from_file(map, filename, srgb, build_mipmaps);
}

#run print("Test:%\n", DIR);