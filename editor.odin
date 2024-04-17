package game

import rl "vendor:raylib"

import "core:fmt"
import "core:math"
import "core:encoding/json"
import "core:os"
import "core:path/filepath"

SCREEN_WIDTH, SCREEN_HEIGHT :: 1920, 1080;

// Tile Variants {Grass, Dirt}

@(private)
Tile :: struct {
 id      : int,
 variant : string,
 pos     : rl.Vector2,
 hitbox  : rl.Rectangle,
}

@(private)
Tile_Data :: struct {
  tiles: [dynamic]Tile,
}

@(private)
Current_Tile :: struct {
  id      : int,
  variant : string,
  texture : rl.Texture2D,
}

@(private)
Cell :: struct {
  rec   : rl.Rectangle,
  pos   : rl.Vector2,
}

main :: proc() { 
  // Initialization
  rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "ZTME");

  rl.SetTargetFPS(60);
  
  // World
  world: World;
  world.tiles = LoadMapFromJSON("map.json");

  /*** Textures ***/
  LoadTextures(&world, "res/tiles/grass");
  LoadTextures(&world, "res/tiles/dirt");
  /*** Textures ***/

  fmt.println(world.variants)

  // Set Tiles Hitbox
  SetHitbox(world);

  // Settings
  showHitbox, showGrid, showCells, gridMode: bool = true, true, false, true;
  
  currentTile: Current_Tile;

  // Camera
  camera: rl.Camera2D;
  camera.offset = {0, 0}
  camera.target = {0,0}
  camera.zoom = 1;

  // Cells
  cells: [dynamic]Cell;

  // Cursor
  cursor: rl.Rectangle;
  cursor.width, cursor.height = 1,1;

  // Exit Key
  rl.SetExitKey(.ESCAPE);

 /*** Game Loop ***/
 for (!rl.WindowShouldClose()) {
  /*** Update ***/
  deltaTime := rl.GetFrameTime();

  // Settings
  if (rl.IsKeyPressed(.KP_1) || rl.IsKeyPressed(.ONE))   {showGrid = !showGrid;}
  if (rl.IsKeyPressed(.KP_2) || rl.IsKeyPressed(.TWO))   {showHitbox = !showHitbox;}
  if (rl.IsKeyPressed(.KP_3) || rl.IsKeyPressed(.THREE)) {gridMode = !gridMode;}

  // Change Current Tile
  if (rl.GetMouseWheelMove() > 0 && currentTile.id != len(world.textures) - 1) {
   currentTile.id += 1;
   fmt.println("Current Tile ID: ", currentTile.id);
  }
  else if (rl.GetMouseWheelMove() < 0 && currentTile.id != 0) {
   currentTile.id -= 1;
   fmt.println("Current Tile ID: ", currentTile.id);
  }

  // Set Current Tile Variant
  if (currentTile.id >= 0 && currentTile.id <= 2) {
    currentTile.variant = "grass";
  }
  else if (currentTile.id >= 3 && currentTile.id <= 8) {
    currentTile.variant = "dirt";
  }

  // Reset Offset
  if (rl.IsKeyPressed(.BACKSPACE)) {camera.offset = {0,0};}

  for _, i in world.textures {
   if (currentTile.id == i) {
    currentTile.texture = world.textures[i];
   }
  }

  // Movement
  if (rl.IsKeyDown(.D))   {camera.offset.x -= 5}
  else if (rl.IsKeyDown(.A) && camera.offset.x != 0) {camera.offset.x += 5}

  if (rl.IsKeyDown(.W) && camera.offset.y != 0)   {camera.offset.y += 5}
  else if (rl.IsKeyDown(.S)) {camera.offset.y -= 5}

  // Cursor
  cursor.x = rl.GetMousePosition().x - camera.offset.x;
  cursor.y = rl.GetMousePosition().y - camera.offset.y;

  // Saving The Map
  if (rl.IsKeyPressed(.ENTER) || rl.IsKeyPressed(.KP_ENTER)) {
    SaveMapToJSON(world, "map.json");
  }

  /*** Update ***/

  /*** Debuging ***/
  /*** Debuging ***/

  /*** Draw ***/
  
  rl.BeginDrawing();
   rl.ClearBackground(rl.Color{40,40,40,255});
   
   rl.BeginMode2D(camera);
    // Draw Tiles
    Draw(&world, showHitbox);

    // Draw Grid
    if (showGrid) {
      for i := 0; i < MAP_WIDTH; i += 1 {
        for j := 0; j < MAP_HEIGHT; j += 1 {
          cell: Cell;
          cell.rec.x = f32(i * TILE_SIZE);
          cell.rec.y = f32(j * TILE_SIZE);
          cell.rec.width, cell.rec.height = TILE_SIZE, TILE_SIZE;

          cell.pos = {f32(i), f32(j)};
          
          append(&cells, cell);

          rl.DrawRectangleLines(i32(i * TILE_SIZE), i32(j * TILE_SIZE), TILE_SIZE,TILE_SIZE, rl.BLACK);
        }
      }
    }

   rl.EndMode2D();
   
   // Draw new tile
   if (rl.IsMouseButtonPressed(.LEFT)) {
    if (gridMode) {
      tile: Tile;
      tile.id = currentTile.id;
      tile.variant = currentTile.variant;

      // Set the new tile position to the current mouse pos cell pos
      for cell in cells {
        if (rl.CheckCollisionRecs(cursor, cell.rec)) {
          tile.pos = cell.pos;
        }
      }

      // Hitbox
      recHitbox: rl.Rectangle = {tile.pos.x * TILE_SIZE, tile.pos.y * TILE_SIZE, TILE_SIZE, TILE_SIZE};
            
      // -1 is air
      if (tile.id != -1) {tile.hitbox = recHitbox;}
      
      fmt.println(tile.variant)
      append(&world.tiles, tile);
    }
    else {

    }

   }

   // Erase Tile
   if (rl.IsMouseButtonPressed(.RIGHT)) {
    if (gridMode) {
      if (world.tiles != nil) {
        for tile, i in world.tiles {
          if (rl.CheckCollisionRecs(cursor, tile.hitbox)) {
            ordered_remove(&world.tiles, i);
          }
        }
      }
    }
    else {

    }
   }

   // Draw Current Tile in the mouse position
   rl.DrawTextureEx(currentTile.texture, rl.GetMousePosition() - {TILE_SIZE / 2, TILE_SIZE / 2}, 0, TILE_SCALE, rl.ColorAlpha(rl.WHITE, 0.4));

   // FPS And Current Tile And Settings
   rl.DrawTextureEx(currentTile.texture, {5, 30}, 0, 3, rl.ColorAlpha(rl.WHITE, 0.4));
   
   rl.DrawText(rl.TextFormat("Show Grid: %t", showGrid), 0, 90, 23, rl.RAYWHITE);
   rl.DrawText(rl.TextFormat("Show Hitbox: %t", showHitbox), 0, 120, 23, rl.RAYWHITE);
   rl.DrawText(rl.TextFormat("Grid Mode: %t", gridMode), 0, 150, 23, rl.RAYWHITE);

   rl.DrawFPS(0, 0);

  rl.EndDrawing();
  /*** Draw ***/
  }
  /*** Game Loop ***/

  // Unload Textures
  for _, i in world.textures {rl.UnloadTexture(world.textures[i]);}
  
  // Close the window
  rl.CloseWindow();
}