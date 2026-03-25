const rl = @import("raylib");
const Player = @import("player.zig").Player;

const GameConfig = struct { screen_width: i32, screen_height: i32, player_width: f32, player_height: f32, player_start_y: f32, bullet_width: f32, bullet_height: f32, shield_starts_x: f32, shield_y: f32, shield_width: f32, shield_height: f32, shield_spacing: f32, invader_start_x: f32, invader_start_y: f32, invader_width: f32, invader_height: f32, invader_spacing_x: f32, invader_spacing_y: f32 };

const config = GameConfig{
    .screen_width = 800,
    .screen_height = 600,
    .player_width = 100.0,
    .player_height = 50.0,
    .player_start_y = 500.0,
    .bullet_width = 5.0,
    .bullet_height = 20.0,
    .shield_starts_x = 350.0,
    .shield_y = 550.0,
    .shield_width = 100.0,
    .shield_height = 20.0,
    .shield_spacing = 10.0,
    .invader_start_x = 50.0,
    .invader_start_y = 100.0,
    .invader_width = 50.0,
    .invader_height = 50.0,
    .invader_spacing_x = 10.0,
    .invader_spacing_y = 10.0,
};

pub fn main() void {
    const screen_width = 800;
    const screen_height = 600;

    const player_width = 50;
    const player_height = 50;

    var player = Player.init(
        @as(f32, @floatFromInt(screen_width)) / 2 - player_width / 2,
        @as(f32, @floatFromInt(screen_height)) - 60.0,
        player_width,
        player_height,
    );

    rl.initWindow(screen_width, screen_height, "Zig Invaders");
    defer rl.closeWindow();

    rl.setTargetFPS(60);

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.black);
        player.update();
        player.draw();

        rl.drawText("Zig Invaders", 300, 250, 40, rl.Color.green);
    }
}
