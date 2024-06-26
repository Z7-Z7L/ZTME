package game

import rl "vendor:raylib"

import "core:fmt"
import "core:encoding/json"
import "core:os"
import "core:path/filepath"
import "core:strings"

TILE_SCALE, TILE_SIZE :: 4, 64;

MAP_WIDTH, MAP_HEIGHT :: 50, 50;

@(private)
Tile :: struct {
 id          : int,
 variant     : string,
 pos         : rl.Vector2,
 hitbox      : rl.Rectangle,
 hitboxState : bool,
}

@(private)
Tile_Data :: struct {
  tiles: [dynamic]Tile,
}

Sprite :: struct {
  texture     : rl.Texture2D,
  variant     : string,
}

World :: struct {
 tiles    : [dynamic]Tile,
 sprites  : [dynamic]Sprite,
}

LoadMapFromJSON :: proc(file: string) -> [dynamic]Tile {
 data, ok := os.read_entire_file_from_filename(file);
 if (!ok) {
   fmt.eprintln("Failed to load the file!");
   return nil;
 }
 defer delete(data);

 result: Tile_Data;
 err := json.unmarshal(data, &result, json.DEFAULT_SPECIFICATION, context.temp_allocator);
 if (err != nil) {
   fmt.eprintln("Failed to parse the json file.");
     fmt.eprintln("Error:", err);
     return nil;
 }  

 // Return all the tiles as a one array
 return result.tiles;
}

DrawWorld :: proc (world: ^World, showHitbox: bool) {
 if (world != nil) {
   for tile in world.tiles {
      rl.DrawTextureEx(world.sprites[tile.id].texture, {tile.pos.x * TILE_SIZE, tile.pos.y * TILE_SIZE}, 0, TILE_SCALE, rl.WHITE);

      color: rl.Color;
      if (tile.hitboxState) {
        color = rl.ColorAlpha(rl.BLUE, 0.3);
      }
      else {
        color = rl.ColorAlpha(rl.GRAY, 0.3);
      }

      if (showHitbox) {
        rl.DrawRectangleRec(tile.hitbox, color);
      }
   }
 }
}

SetTilesHitbox :: proc(world: World) {
 if (world.tiles != nil) {
   for &tile in world.tiles {
     recHitbox: rl.Rectangle = {tile.pos.x * TILE_SIZE, tile.pos.y * TILE_SIZE, TILE_SIZE, TILE_SIZE};
     
     // -1 is air
     if (tile.id != -1) {tile.hitbox = recHitbox;}
   }
 }
}

LoadTexturesToWorld :: proc(world: ^World, path: string) {
  Local_State :: struct {
    total_entries : int,
    path          : string,
    texturess     : [dynamic]rl.Texture2D,
  }
 
  localState := Local_State{path = path};

  if (os.is_dir(path)) {
    filepath.walk(path, proc(info: os.File_Info, prev_err: os.Errno, user_data: rawptr) -> (err: os.Errno, skip_dir: bool) {
      localState := (^Local_State)(user_data);
      
      filePath := fmt.tprintf("%s/%d.png", localState.path, localState.total_entries);

      if (os.is_file(string(filePath))) {
        current_texture := rl.LoadTexture(strings.clone_to_cstring(filePath));

        append(&localState.texturess, current_texture);
        
        localState.total_entries += 1;
      }
     
      return 0, false
    }, &localState.total_entries);

    parts := strings.split(path, "/");
    vari := parts[len(parts) - 1];

    for t in localState.texturess {
      sp: Sprite;
      sp.texture = t;
      sp.variant = vari;

      append(&world.sprites, sp);
    }
  }
  else {
    fmt.eprintln("ERROR: The given path is not a directory!");
  }
}