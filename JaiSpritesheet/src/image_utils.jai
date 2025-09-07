Simp :: #import "Simp";
Texture :: Simp.Texture;

expand_image :: (texture : *Texture, horizontal_buffer : int = 4, vertical_buffer : int = 4) {
  width := texture.width + (2 * horizontal_buffer);
  height := texture.height + (2 * vertical_buffer);
}

trim_translucent :: () {
  
}