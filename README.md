# JaiSpritesheet
This module lets you automatically build texture atlases from individual image files at compile time. It efficiently packs multiple textures into one or more atlases, reducing draw calls and improving rendering performance.

Atlas generation is powered by the MaxRects bin-packing algorithm, adapted from [juj/RectangleBinPack](https://github.com/juj/RectangleBinPack/tree/master)

## How to use

### Flags

| Flag Name      | Type  | Default | Description |
|----------------|-------|---------|-------------|
| `TRIM_ALPHA`   | bool  | `true`  | Removes any fully transparent areas surrounding the input images. |
| `TILING_BUFFER`| int   | `4`     | Adds a buffer around each sprite when packing images. This prevents floating-point sampling errors from showing seams between adjacent sprites by duplicating edge pixels. |


## Example Project


## Credits and Acknowledgements
- Images for the `example` project are CreativeCommons assets that can be redistributed for free. They came from here:
https://kenney.nl/assets/sokoban

- MaxRectsBinPack algorithm came from this repository and was ported to `jai` by hand in an exercise to get more familiar with the language. 
https://github.com/juj/RectangleBinPack/tree/master