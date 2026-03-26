const rl = @import("raylib");
const Rectangle = @import("rectangle.zig").Rectangle;

pub const Player = struct {
    position_x: f32,
    position_y: f32,
    width: f32,
    height: f32,
    speed: f32,

    pub inline fn init(
        position_x: f32,
        position_y: f32,
        width: f32,
        height: f32,
    ) @This() {
        return .{
            .position_x = position_x,
            .position_y = position_y,
            .width = width,
            .height = height,
            .speed = 5.0,
        };
    }

    pub inline fn update(self: *@This()) void {
        if (rl.isKeyDown(rl.KeyboardKey.right)) {
            self.position_x += self.speed;
        }

        if (rl.isKeyDown(rl.KeyboardKey.left)) {
            self.position_x -= self.speed;
        }

        if (rl.isKeyDown(rl.KeyboardKey.up)) {
            self.position_y -= self.speed;
        }

        if (rl.isKeyDown(rl.KeyboardKey.down)) {
            self.position_y += self.speed;
        }

        if (self.position_x < 0) {
            self.position_x = 0;
        }

        if (self.position_x + self.width > @as(f32, @floatFromInt(rl.getScreenWidth()))) {
            self.position_x = @as(f32, @floatFromInt(rl.getScreenWidth())) - self.width;
        }

        if (self.position_y + self.height > @as(f32, @floatFromInt(rl.getScreenHeight()))) {
            self.position_y = @as(f32, @floatFromInt(rl.getScreenHeight())) - self.height;
        }

        if (self.position_y < 0) {
            self.position_y = 0;
        }
    }

    pub fn draw(self: @This()) void {
        const x = @as(i32, @intFromFloat(@round(self.position_x)));
        const y = @as(i32, @intFromFloat(@round(self.position_y)));
        const w = @as(i32, @intFromFloat(self.width));
        const h = @as(i32, @intFromFloat(self.height));

        const stripe_h = @divTrunc(h, 3);

        const BLUE = rl.Color{ .r = 0, .g = 57, .b = 166, .a = 255 };
        const RED = rl.Color{ .r = 213, .g = 43, .b = 30, .a = 255 };

        rl.drawRectangle(x, y, w, stripe_h, BLUE);
        rl.drawRectangle(x, y + stripe_h, w, stripe_h, BLUE);
        rl.drawRectangle(x, y + stripe_h * 2, w, h - stripe_h * 2, RED);
    }

    pub fn getRect(self: @This()) Rectangle {
        return .{
            .x = self.position_x,
            .y = self.position_y,
            .width = self.width,
            .height = self.height,
        };
    }
};
