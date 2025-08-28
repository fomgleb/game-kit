const std = @import("std");
const sdl = @import("sdl.zig");
const config = @import("config");

/// Add assets in `build.zig` with this function.
pub fn addAsset(b: *std.Build, mod: *std.Build.Module, asset_path: []const u8) void {
    mod.addAnonymousImport(asset_path, .{ .root_source_file = b.path(asset_path) });
}

/// Returned buffer should be deallocated with `freeReadFile`.
pub fn readFileAlloc(dir: std.fs.Dir, allocator: std.mem.Allocator, comptime file_path: []const u8, max_bytes: usize) ![]const u8 {
    if (config.embed_resources)
        return @embedFile(file_path)
    else
        return try dir.readFileAlloc(allocator, file_path, max_bytes);
}

/// Deallocates the buffer returned by `readFileAlloc`.
pub fn freeReadFile(allocator: std.mem.Allocator, file: []const u8) void {
    if (!config.embed_resources) allocator.free(file);
}

pub fn openIoStream(comptime path: [:0]const u8) error{SdlError}!*sdl.IoStream {
    const io_stream = blk: {
        if (config.embed_resources) {
            const file_content = @embedFile(path);
            break :blk try sdl.ioFromConstMem(file_content);
        } else {
            break :blk try sdl.ioFromFile(path, "r");
        }
    };

    return io_stream;
}

/// Returned texture can be deallocated with `SDL_DestroyTexture`.
pub fn loadTexture(renderer: *sdl.Renderer, comptime path: [:0]const u8, scale_mode: sdl.ScaleMode) !*sdl.Texture {
    const texture = try sdl.loadTextureIo(renderer, try openIoStream(path), true);
    try sdl.setTextureScaleMode(texture, scale_mode);
    return texture;
}
