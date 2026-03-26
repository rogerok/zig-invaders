const rl = @import("raylib");
const Rectangle = @import("rectangle.zig").Rectangle;

pub const Shield = struct {
    position_x: f32,
    position_y: f32,
    width: f32,
    height: f32,
    health: i32,

    pub fn init(position_x: f32, position_y: f32, width: f32, height: f32) @This() {
        return .{
            .position_x = position_x,
            .position_y = position_y,
            .width = width,
            .height = height,
            .health = 10,
        };
    }

    pub fn hit(self: *@This()) void {
        self.health -= 1;
    }

    pub fn draw(self: @This()) void {
        if (self.health > 0) {
            const alpha = @as(u8, @intCast(@min(255, self.health * 25)));

            const x = @as(i32, @intFromFloat(@round(self.position_x)));
            const y = @as(i32, @intFromFloat(@round(self.position_y)));
            const w = @as(i32, @intFromFloat(@round(self.width)));
            const h = @as(i32, @intFromFloat(@round(self.height)));

            const stripe_h = @divTrunc(h, 3);

            const BLACK = rl.Color{ .r = 0, .g = 0, .b = 0, .a = alpha };
            const RED = rl.Color{ .r = 213, .g = 43, .b = 30, .a = alpha };

            rl.drawRectangle(x, y + stripe_h, w, stripe_h, BLACK);
            rl.drawRectangle(x, y + stripe_h * 2, w, h - stripe_h * 2, RED);
        }
    }

    pub fn isActive(self: @This()) bool {
        return self.health > 0;
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
