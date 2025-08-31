pub fn Vec3(T: type) type {
    return struct {
        const Self = @This();

        x: T,
        y: T,
        z: T,

        pub const zero: Self = .{ .x = 0, .y = 0, .z = 0 };

        pub fn init(x: T, y: T, z: T) Self {
            return .{ .x = x, .y = y, .z = z };
        }

        pub fn as(self: Self, NewType: type) Vec3(NewType) {
            return Vec3(NewType){ .x = self.x, .y = self.y, .z = self.z };
        }

        pub fn intCast(self: Self, NewType: type) Vec3(NewType) {
            return Vec3(NewType){ .x = @intCast(self.x), .y = @intCast(self.y), .z = @intCast(self.z) };
        }

        pub fn floatFromInt(self: Self, NewType: type) Vec3(NewType) {
            return Vec3(NewType){ .x = @floatFromInt(self.x), .y = @floatFromInt(self.y), .z = @floatFromInt(self.z) };
        }

        pub fn intFromFloat(self: Self, NewType: type) Vec3(NewType) {
            return Vec3(NewType){ .x = @intFromFloat(self.x), .y = @intFromFloat(self.y), .z = @intFromFloat(self.z) };
        }

        pub fn round(self: Self) Self {
            return .{ .x = @round(self.x), .y = @round(self.y), .z = @round(self.z) };
        }

        pub fn ceil(self: Self) Self {
            return .{ .x = @ceil(self.x), .y = @ceil(self.y), .z = @ceil(self.z) };
        }

        pub fn floor(self: Self) Self {
            return .{ .x = @floor(self.x), .y = @floor(self.y), .z = @floor(self.z) };
        }

        pub fn mulNum(self: Self, num: T) Self {
            return .{ .x = self.x * num, .y = self.y * num, .z = self.z * num };
        }

        pub fn divNum(self: Self, num: T) Self {
            return .{ .x = self.x / num, .y = self.y / num, .z = self.z / num };
        }

        pub fn addNum(self: Self, num: T) Self {
            return .{ .x = self.x + num, .y = self.y + num, .z = self.z + num };
        }

        pub fn subNum(self: Self, num: T) Self {
            return .{ .x = self.x - num, .y = self.y - num, .z = self.z - num };
        }

        pub fn modNum(self: Self, num: T) Self {
            return .{ .x = self.x % num, .y = self.y % num, .z = self.z % num };
        }

        pub fn mul(self: Self, other: Self) Self {
            return .{ .x = self.x * other.x, .y = self.y * other.y, .z = self.z * other.z };
        }

        pub fn div(self: Self, other: Self) Self {
            return .{ .x = self.x / other.x, .y = self.y / other.y, .z = self.z / other.z };
        }

        pub fn add(self: Self, other: Self) Self {
            return .{ .x = self.x + other.x, .y = self.y + other.y, .z = self.z + other.z };
        }

        pub fn sub(self: Self, other: Self) Self {
            return .{ .x = self.x - other.x, .y = self.y - other.y, .z = self.z - other.z };
        }

        pub fn mod(self: Self, other: Self) Self {
            return .{ .x = self.x % other.x, .y = self.y % other.y, .z = self.z % other.z };
        }

        pub fn max(self: Self) T {
            return @max(self.x, self.y, self.z);
        }

        pub fn min(self: Self) T {
            return @min(self.x, self.y, self.z);
        }
    };
}
