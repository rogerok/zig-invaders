const rl = @import("raylib");
const Rectangle = @import("rectangle.zig").Rectangle;

pub const EnemyBullet = struct {
    position_x: f32,
    position_y: f32,
    width: f32,
    height: f32,
    speed: f32,
    active: bool,

    pub fn init(
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
            .speed = 3.0,
            .active = false,
        };
    }

    pub fn draw(self: @This()) void {
        if (self.active) {
            rl.drawRectangle(
                @as(i32, @intFromFloat(@round(self.position_x))),
                @as(i32, @intFromFloat(@round(self.position_y))),
                @as(i32, @intFromFloat(@round(self.width))),
                @as(i32, @intFromFloat(@round(self.height))),
                rl.Color.yellow,
            );
        }
    }

    pub fn getRect(self: @This()) Rectangle {
        return .{
            .x = self.position_x,
            .y = self.position_y,
            .width = self.width,
            .height = self.height,
        };
    }

    pub fn update(self: *@This(), screen_height: f32) void {
        if (self.active) {
            self.position_y += self.speed;
            if (self.position_y > screen_height) {
                self.active = false;
            }
        }
    }
};
