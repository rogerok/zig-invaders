const rl = @import("raylib");
const Player = @import("player.zig").Player;
const Bullet = @import("bullet.zig").Bullet;
const Invader = @import("invader.zig").Invader;
const Rectangle = @import("rectangle.zig").Rectangle;
const EnemyBullet = @import("enemy_bullet.zig").EnemyBullet;
const Shield = @import("shield.zig").Shield;

const GameConfig = struct { screen_width: i32, screen_height: i32, player_width: f32, player_height: f32, player_start_y: f32, bullet_width: f32, bullet_height: f32, shield_starts_x: f32, shield_y: f32, shield_width: f32, shield_height: f32, shield_spacing: f32, invader_start_x: f32, invader_start_y: f32, invader_width: f32, invader_height: f32, invader_spacing_x: f32, invader_spacing_y: f32 };

fn resetGame(player: *Player, bullets: []Bullet, enemy_bullets: []EnemyBullet, shields: []Shield, invaders: anytype, invader_direction: *f32, score: *i32, conf: GameConfig) void {
    score.* = 0;
    player.* = Player.init(
        @as(f32, @floatFromInt(conf.screen_width)) / 2 - conf.player_width / 2,
        @as(f32, @floatFromInt(conf.screen_height)) - 60.0,
        conf.player_width,
        conf.player_height,
    );

    for (bullets) |*bullet| {
        bullet.active = false;
    }

    for (enemy_bullets) |*bullet| {
        bullet.active = false;
    }

    for (shields, 0..) |*shield, i| {
        const x = conf.shield_starts_x + @as(f32, @floatFromInt(i)) * conf.shield_spacing;
        shield.* = Shield.init(x, conf.shield_y, conf.shield_width, conf.shield_height);
    }

    for (invaders, 0..) |*row, i| {
        for (row, 0..) |*invader, j| {
            const x = conf.invader_start_x + @as(f32, @floatFromInt(j)) * conf.invader_spacing_x;
            const y = conf.invader_start_y + @as(f32, @floatFromInt(i)) * conf.invader_spacing_y;
            invader.* = Invader.init(x, y, conf.invader_width, conf.invader_height);
        }
    }

    invader_direction.* = 1.0;
}

pub fn main() void {
    const screen_width = 800;
    const screen_height = 600;
    const font_size = 40;

    const player_width = 50;
    const player_height = 50;

    const max_bullets = 10;
    const bullet_width = 4.0;
    const bullet_height = 10.0;

    const invader_rows = 5;
    const invader_cols = 11;
    const invader_width = 30;
    const ivader_height = 30;
    const invader_start_x = 100.0;
    const invader_start_y = 50.0;
    const invader_spacing_x = 60.0;
    const invader_spacing_y = 40.0;
    const invader_speed = 5.0;
    const invader_move_delay = 30;
    const invader_drop_distance = 20;
    const max_enemy_bullets = 20;
    const enemy_shoot_delay = 60;
    const enemy_shoot_chance = 5;

    const shield_count = 4;
    const shield_width = 80.0;
    const shield_height = 60.0;
    const shield_start_x = 150.0;
    const shield_start_y = 450.0;
    const shield_spacing = 150.0;

    var show_title: bool = true;
    var show_title_timer: f32 = 0;

    var game_over: bool = false;
    var game_won: bool = false;
    var score: i32 = 0;

    var enemy_shoot_timer: i32 = 0;

    var invader_move_direction: f32 = 1.0;
    var move_timer: i32 = 0;

    const game_config = GameConfig{
        .screen_width = screen_width,
        .screen_height = screen_height,
        .player_width = @as(f32, @floatFromInt(player_width)),
        .player_height = @as(f32, @floatFromInt(player_height)),
        .player_start_y = @as(f32, @floatFromInt(screen_height)) - 60.0,

        .bullet_width = bullet_width,
        .bullet_height = bullet_height,

        .shield_starts_x = shield_start_x,
        .shield_y = shield_start_y,
        .shield_width = shield_width,
        .shield_height = shield_height,
        .shield_spacing = shield_spacing,

        .invader_start_x = invader_start_x,
        .invader_start_y = invader_start_y,
        .invader_width = @as(f32, @floatFromInt(invader_width)),
        .invader_height = @as(f32, @floatFromInt(ivader_height)),
        .invader_spacing_x = invader_spacing_x,
        .invader_spacing_y = invader_spacing_y,
    };

    var player = Player.init(
        @as(f32, @floatFromInt(screen_width)) / 2 - player_width / 2,
        @as(f32, @floatFromInt(screen_height)) - 60.0,
        player_width,
        player_height,
    );

    var shields: [shield_count]Shield = undefined;

    for (&shields, 0..) |*shield, i| {
        const x = shield_start_x + @as(f32, @floatFromInt(i)) * shield_spacing;
        shield.* = Shield.init(x, shield_start_y, shield_width, shield_height);
    }

    var bullets: [max_bullets]Bullet = undefined;

    for (&bullets) |*bullet| {
        bullet.* = Bullet.init(0.0, 0.0, bullet_width, bullet_height);
    }

    var enemy_bullets: [max_enemy_bullets]EnemyBullet = undefined;

    for (&enemy_bullets) |*bullet| {
        bullet.* = EnemyBullet.init(0.0, 0.0, bullet_width, bullet_height);
    }

    var invaders: [invader_rows][invader_cols]Invader = undefined;

    for (&invaders, 0..) |*row, i| {
        for (row, 0..) |*invader, j| {
            const x = invader_start_x + @as(f32, @floatFromInt(j)) * invader_spacing_x;
            const y = invader_start_y + @as(f32, @floatFromInt(i)) * invader_spacing_y;
            invader.* = Invader.init(x, y, invader_width, ivader_height);
        }
    }

    rl.initWindow(screen_width, screen_height, "Zig Invaders");
    defer rl.closeWindow();

    rl.setTargetFPS(60);

    while (!rl.windowShouldClose()) {
        show_title_timer += rl.getFrameTime();

        if (show_title_timer >= 5.0) {
            show_title = false;
        }

        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.black);

        if (game_over) {
            rl.drawText("GAME OVER.\n PRESS ENTER \n TO SIGN CONTRACT AGAIN", 200, 200, font_size, rl.Color.red);
            const score_text = rl.textFormat("Final Score %d", .{score});
            rl.drawText(score_text, 320, 400, font_size, rl.Color.white);

            if (rl.isKeyPressed(rl.KeyboardKey.enter)) {
                game_over = false;

                resetGame(
                    &player,
                    &bullets,
                    &enemy_bullets,
                    &shields,
                    &invaders,
                    &invader_move_direction,
                    &score,
                    game_config,
                );
            }
        }

        if (game_won) {
            rl.drawText("YOU WIN.\n PRESS ENTER \n TO SIGN CONTRACT AGAIN", 200, 200, font_size, rl.Color.gold);
            const score_text = rl.textFormat("Final Score %d", .{score});
            rl.drawText(score_text, 320, 400, font_size, rl.Color.white);

            if (rl.isKeyPressed(rl.KeyboardKey.enter)) {
                game_won = false;

                resetGame(
                    &player,
                    &bullets,
                    &enemy_bullets,
                    &shields,
                    &invaders,
                    &invader_move_direction,
                    &score,
                    game_config,
                );
            }
        }

        player.update();
        if (rl.isKeyPressed(rl.KeyboardKey.space)) {
            for (&bullets) |*bullet| {
                if (!bullet.active) {
                    bullet.position_x = player.position_x + player.width / 2 - bullet.width / 2;
                    bullet.position_y = player.position_y;
                    bullet.active = true;
                    break;
                }
            }
        }

        var all_invaders_dead: bool = true;

        outer_loop: for (&invaders) |*row| {
            for (&row.*) |*invader| {
                if (invader.alive) {
                    all_invaders_dead = false;
                    break :outer_loop;
                }
            }
        }

        if (all_invaders_dead) {
            game_won = true;
        }

        // DRAW LOGIC
        for (&shields) |*shield| {
            shield.draw();
        }

        player.draw();

        for (&bullets) |*bullet| {
            bullet.draw();
        }

        for (&invaders) |*row| {
            for (&row.*) |*invader| {
                invader.draw();
            }
        }

        for (&enemy_bullets) |*bullet| {
            bullet.draw();
        }

        for (&bullets) |*bullet| {
            bullet.update();
        }

        for (&bullets) |*bullet| {
            if (bullet.active) {
                for (&invaders) |*row| {
                    for (row) |*invader| {
                        if (invader.alive) {
                            if (bullet.getRect().intersects(invader.getRect())) {
                                invader.alive = false;
                                bullet.active = false;
                                score += 10;
                                break;
                            }
                        }
                    }
                }

                for (&shields) |*shield| {
                    if (shield.health > 0) {
                        if (bullet.getRect().intersects(shield.getRect())) {
                            bullet.active = false;
                            shield.hit();
                            break;
                        }
                    }
                }
            }
        }

        for (&enemy_bullets) |*bullet| {
            bullet.update(screen_height);
            if (bullet.active) {
                if (bullet.getRect().intersects(player.getRect())) {
                    bullet.active = false;
                    game_over = true;
                }

                for (&shields) |*shield| {
                    if (shield.health > 0) {
                        if (bullet.getRect().intersects(shield.getRect())) {
                            bullet.active = false;
                            shield.hit();
                            break;
                        }
                    }
                }
            }
        }

        enemy_shoot_timer += 1;
        if (enemy_shoot_timer >= enemy_shoot_delay) {
            enemy_shoot_timer = 0;

            for (&invaders) |*row| {
                for (row) |*invader| {
                    if (invader.alive and rl.getRandomValue(0, 100) < enemy_shoot_chance) {
                        for (&enemy_bullets) |*bullet| {
                            if (!bullet.active) {
                                bullet.position_x = invader.position_x + invader.width / 2 - bullet.width / 2;
                                bullet.position_y = invader.position_y + invader.height;
                                bullet.active = true;
                                break;
                            }
                        }
                        break;
                    }
                }
            }
        }

        move_timer += 1;
        if (move_timer >= invader_move_delay) {
            move_timer = 0;

            var hit_edge = false;
            for (&invaders) |*row| {
                for (row) |*invader| {
                    if (invader.alive) {
                        const next_x = invader.position_x + (invader_speed * invader_move_direction);

                        if (next_x < 0 or next_x + invader.width > @as(f32, @floatFromInt(screen_width))) {
                            hit_edge = true;
                            break;
                        }
                    }
                }

                if (hit_edge) {
                    break;
                }
            }

            if (hit_edge) {
                invader_move_direction *= -1.0;
                for (&invaders) |*row| {
                    for (row) |*invader| {
                        invader.update(0.0, invader_drop_distance);
                    }
                }
            } else {
                for (&invaders) |*row| {
                    for (row) |*invader| {
                        invader.update(invader_speed * invader_move_direction, 0.0);
                    }
                }
            }

            for (&invaders) |*row| {
                for (row) |*invader| {
                    if (invader.alive) {
                        if (invader.getRect().intersects(player.getRect())) {
                            game_over = true;
                        }
                    }
                }
            }
        }

        if (show_title) {
            rl.drawText("ZIG Invaders", 250, 200, font_size, rl.Color.green);
        }

        const score_text = rl.textFormat("Score: %d", .{score});

        rl.drawText(score_text, 30, screen_height - 20, 15, rl.Color.green);
    }
}
