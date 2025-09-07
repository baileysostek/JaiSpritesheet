#module_parameters(DIR : string = #filepath);

#scope_file

#import "Basic";
#import "File_Utilities";
#import "String";
#import "Hash_Table";
#import "Math";
#import "Random";
#import "stb_image_write";

// Simp Imports
Simp    :: #import "Simp";
Bitmap :: Simp.Bitmap;
Texture :: Simp.Texture;
TextureFormat :: Simp.Texture_Format;

// Source Files
#load "src/rect.jai";
#load "src/binary_packer.jai";

_ends_width_any :: (s: string, suffix: []string) -> bool {
  for it : suffix {
    if ends_with(s, it) return true;
  }
  return false;
}

_compute_optimal_size :: () -> u32{
  total_area : u64 = 0;
  for rect : rects {
    total_area += xx(rect.width * rect.height);
  }
  return xx ceil(sqrt(cast(float64) total_area));
}

to_pack : [..] *Rect;

#scope_export
texture_load_from_file :: (map: *Texture, filename: string, dst : *[..] *Rect, srgb:=false, build_mipmaps:=false) -> bool {
  return Simp.texture_load_from_file(map, filename, srgb, build_mipmaps);
}

add_dir :: (dir_path : string, recursive := true, follow_directory_symlinks := true, allowed_formats : []string = .[".png", ".jpg"]) {
  // source files
  files := file_list(tprint("%1%2", #filepath, dir_path), recursive=recursive, follow_directory_symlinks=follow_directory_symlinks);
  for file: files {
    // Validate that the file can be added.
    if !_ends_width_any(file, allowed_formats) {
      print("File: \"%\" not added.\n", file);
      continue;
    }
    // Try to open and load the file
    image: Texture;
    success := Simp.texture_load_from_file(*image, file);
    assert(success, tprint("Error loading file:%\n", file));

    print("Test:%\n", image);
    rect := New(Rect);
    rect.width = image.width;
    rect.height = image.height;
    rect.file_path = file;
    array_add(*to_pack, rect);

    // Cleanup our texture
    Simp.texture_destroy(*image);
  }
}

build :: (output_path : string = "", format : TextureFormat = .RGBA8) {
  // Generate the filename
  filename := tprint("%1%2\0", #filepath, output_path);
  print("Building Atlas:%\n", filename);

  // Build texture atlas
  dst : [..] *Rect;
  width, height, utilization := MaxRectsBinPack.pack_rects(to_pack, *dst);
  print("Solution found: [%1,%2] utilization:%\%\n", width, height, utilization * 100);
  // Write bitmap to disk
  bitmap := New(Bitmap);
  Simp.bitmap_alloc(bitmap, xx width, xx height, format);
  // Load every image and draw it to the simp bitmap.
  for dst {
    print("%\n", it.*);
    image: Texture;
    success := Simp.texture_load_from_file(*image, it.file_path);
    assert(success, tprint("Error loading file:%\n", it.file_path));
    defer Simp.texture_destroy(*image);
    async_read := Simp.pixel_read_begin(*image, format);
    image_bitmap := Simp.pixel_read_end(async_read);
    bitmap_blit(bitmap, *image_bitmap, xx it.x, xx it.y);
  }

  bytes_per_texel := Simp.get_image_bytes_per_texel(bitmap.format);
  stbi_write_png(filename.data, bitmap.width, bitmap.height, xx bytes_per_texel, bitmap.data.data, xx (bitmap.width * bytes_per_texel));
  Simp.deinit(bitmap);
}

// TODO: Memcopy instead for speed.
bitmap_blit :: (dst: *Bitmap, src: *Bitmap, dst_x: s32, dst_y: s32) {
  bytes_per_texel := Simp.get_image_bytes_per_texel(dst.format);
  assert(dst.format == src.format);

  for row: 0..src.height-1 {
    dst_row_start := (dst_y + row) * dst.stride + dst_x * bytes_per_texel;
    src_row_start := row * src.stride;

    for col: 0..(src.width * bytes_per_texel - 1) {
      dst.data[dst_row_start + col] = src.data[src_row_start + col];
    }
  }
}