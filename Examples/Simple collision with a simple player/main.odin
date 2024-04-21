/***

Simple example for how to use the tilemap collision with a simple player

Note: The player have a simple physics so it may have some glitches

***/

package game

import rl "vendor:raylib"
import "core:fmt"
import "core:strings"

SCREEN_WIDTH, SCREEN_HEIGHT :: 1280, 720;

main :: proc() {
  // Initialization
  rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Game");
  rl.SetTargetFPS(60);
  
  // Create a world
  world: World;

  // Load map
  world.tiles = LoadMapFromJSON("map.json")

  // Load Textures
  LoadTexturesToWorld(&world, "res/tiles/grass");
  LoadTexturesToWorld(&world, "res/tiles/dirt");

  // Set Hitbox for world tiles
  SetTilesHitbox(world);

  // Player
  player: Player;
  player.rec = {500, 90, 40, 90};
  player.color = rl.RED;
  player.speed = 150;
  player.gravity = 3;
  player.jumpStrength = 500;

  enable_all_hitbox_states: bool

  /*** Game Loop ***/
  for (!rl.WindowShouldClose()) {
    // Delta Time
    deltaTime := rl.GetFrameTime();

    // Update
    Update_Player(&player, &world, deltaTime, enable_all_hitbox_states);

    if (rl.IsKeyPressed(.ONE)) {
      enable_all_hitbox_states = !enable_all_hitbox_states;
    }

    /*** Draw ***/
    rl.BeginDrawing();
      rl.ClearBackground(rl.Color{40,40,40, 255});

      DrawWorld(&world, true);

      // Player
      Draw_Player(&player);

      // Draw FPS & Text
      rl.DrawFPS(0, 0);
      rl.DrawText(strings.clone_to_cstring(fmt.tprintf("Enable All Hitbox States: %t", enable_all_hitbox_states)), 0, 20, 23, rl.RAYWHITE);
    rl.EndDrawing();
    /*** Draw ***/
  }
  /*** Game Loop ***/

  // Close the window
  rl.CloseWindow();
}