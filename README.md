# ZTME
 My own tile editor for raylib

To use run `ZTME.exe` and it will start the editor

NOTE: the Grid Mode isn't working for now I will do it later

Controls:
Show Grid: one or num1 in the keyboard
Show Hitbox: two or num2 in the keyboard
Eanble / Disable Grid Mode: three or num3 in the keyboard

After you finish the map you just press `Enter` and it will save the map for you in a `map.json` (even if there is no `map.json` it will create `map.json` for you)

Here is a example to how to load the map

```c++ 
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
```
