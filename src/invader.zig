const rl = @import("raylib");
const Rectangle = @import("rectangle.zig").Rectangle;

pub const Invader = struct {
    position_x: f32,
    position_y: f32,
    width: f32,
    height: f32,
    speed: f32,
    alive: bool,

    pub fn init(position_x: f32, position_y: f32, width: f32, height: f32) @This() {
        return .{
            .position_x = position_x,
            .position_y = position_y,
            .width = width,
            .height = height,
            .speed = 5.0,
            .alive = true,
        };
    }

    pub fn draw(self: @This()) void {
        if (self.alive) {
            const x = @as(i32, @intFromFloat(@round(self.position_x)));
            const y = @as(i32, @intFromFloat(@round(self.position_y)));
            const w = @as(i32, @intFromFloat(self.width));
            const h = @as(i32, @intFromFloat(self.height));

            const stripe_h = @divTrunc(h, 3);

            rl.drawRectangle(x, y, w, stripe_h, rl.Color.green);
            rl.drawRectangle(x, y + stripe_h, w, stripe_h, rl.Color.white);
        }
    }

    pub fn update(self: *@This(), dx: f32, dy: f32) void {
        self.position_x += dx;
        self.position_y += dy;
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
