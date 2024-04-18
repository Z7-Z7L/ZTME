package game

import rl "vendor:raylib"
import "core:fmt"

SCREEN_WIDTH, SCREEN_HEIGHT :: 1280, 720;

main :: proc() {
  // Initialization
  rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Game");
  rl.SetTargetFPS(60);

  world: World;
  world.tiles = LoadMapFromJSON("map.json")

  LoadTexturesToWorld(&world, "res/tiles/grass");
  LoadTexturesToWorld(&world, "res/tiles/dirt");

  SetTilesHitbox(world);

  /*** Game Loop ***/
  for (!rl.WindowShouldClose()) {
    /*** Draw ***/
    rl.BeginDrawing();
      rl.ClearBackground(rl.RAYWHITE);

      DrawWorld(&world, false);

      // Draw FPS
      rl.DrawFPS(0, 0);

    rl.EndDrawing();
    /*** Draw ***/
  }
  /*** Game Loop ***/

  // Close the window
  rl.CloseWindow();
}