package game

import "core:fmt"
import rl "vendor:raylib"

CollisionSide :: enum {NONE, RIGHT, LEFT, TOP, BOTTOM};

CheckCollisionReturnSide :: proc(rec1, rec2: rl.Rectangle) -> CollisionSide {
  colSide: CollisionSide;

  overlapArea := rl.GetCollisionRec(rec1, rec2);

  if (overlapArea.height > overlapArea.width) {
    if (overlapArea.x <= rec1.x) {
      colSide = CollisionSide.LEFT;
    }
    else {
      colSide = CollisionSide.RIGHT;
    }
  }

  if (overlapArea.width > overlapArea.height) {
    if (overlapArea.y <= rec1.y) {
      colSide = CollisionSide.TOP;
    }
    else {
      colSide = CollisionSide.BOTTOM;
    }
  }

  return colSide;
}

Player :: struct {
 rec          : rl.Rectangle,
 color        : rl.Color, 
 velocity     : rl.Vector2,
 speed        : f32,
 gravity      : f32,
 jumpStrength : f32,
}

Update_Player :: proc(p: ^Player, world: ^World, deltaTime: f32, enable_all_hitbox_states: bool) {
  // Apply velocity to player rec
  p.rec.x += p.velocity.x * deltaTime;
  p.rec.y += p.velocity.y * deltaTime;

  // Movement
  if (rl.IsKeyDown(.RIGHT) || rl.IsKeyDown(.D))     {p.velocity.x = p.speed;}
  else if (rl.IsKeyDown(.LEFT) || rl.IsKeyDown(.A)) {p.velocity.x = -p.speed;}
  else {p.velocity.x = 0;}
 
  // Check Collision
  if (world.tiles != nil) {
    for tile in world.tiles {
      if (tile.hitboxState && tile.variant == "grass") {
        colSide := CheckCollisionReturnSide(p.rec, tile.hitbox);

        if (colSide == .BOTTOM) {
          p.velocity.y = 0;
          if (rl.IsKeyDown(.UP) || rl.IsKeyDown(.W) || rl.IsKeyDown(.SPACE)) {
            p.velocity.y = -p.jumpStrength;
          }
          break;
        }
        else {
          p.velocity.y += p.gravity;
        }
      }
      else if (enable_all_hitbox_states && tile.variant == "grass") {
        colSide := CheckCollisionReturnSide(p.rec, tile.hitbox);

        if (colSide == .BOTTOM) {
          p.velocity.y = 0;
          if (rl.IsKeyDown(.UP) || rl.IsKeyDown(.W) || rl.IsKeyDown(.SPACE)) {
            p.velocity.y = -p.jumpStrength;
          }
          break;
        }
        else {
          p.velocity.y += p.gravity;
        }
      }
    }
  }

  if (world.tiles != nil) {
    for tile in world.tiles {
      if (enable_all_hitbox_states) {
        if (!tile.hitboxState && tile.variant == "grass") {
          colSide := CheckCollisionReturnSide(p.rec, tile.hitbox);
  
          if (colSide == .RIGHT || colSide == .LEFT) {
            p.velocity.x = -p.velocity.x;
          }
        }
      }
    }
  }
}

Draw_Player :: proc(p: ^Player) {
  rl.DrawRectangleRec(p.rec, p.color);
}