const Color = @import("Color.zig");
const log = @import("std").log.scoped(.sdl);
const Allocator = @import("std").mem.Allocator;
const Vec2 = @import("Vec2.zig").Vec2;
const Rect = @import("Rect.zig").Rect;

pub const c = @import("c.zig").c;

pub const InitFlags = c.SDL_InitFlags;
pub const WindowFlags = c.SDL_WindowFlags;
pub const Window = c.SDL_Window;
pub const Renderer = c.SDL_Renderer;
pub const Texture = c.SDL_Texture;
pub const IoStream = c.SDL_IOStream;
pub const Surface = c.SDL_Surface;
pub const Event = c.SDL_Event;

pub const quit = c.SDL_Quit;
pub const quitSubSystem = c.SDL_QuitSubSystem;
pub const destroyWindow = c.SDL_DestroyWindow;
pub const destroyRenderer = c.SDL_DestroyRenderer;
pub const destroyTexture = c.SDL_DestroyTexture;
pub const destroySurface = c.SDL_DestroySurface;

pub fn initSubSystem(flags: InitFlags) error{SdlError}!void {
    if (!c.SDL_InitSubSystem(flags)) {
        log.err("Failed to SDL_InitSubSystem: {s}", .{c.SDL_GetError()});
        return error.SdlError;
    }
}

pub fn createWindow(title: [*:0]const u8, size: Vec2(u32), flags: WindowFlags) error{SdlError}!*Window {
    return c.SDL_CreateWindow(title, @intCast(size.x), @intCast(size.y), flags) orelse {
        log.err("Failed to SDL_CreateWindow: {s}", .{c.SDL_GetError()});
        return error.SdlError;
    };
}

pub fn createRenderer(window: *Window, name: ?[*:0]const u8) error{SdlError}!*Renderer {
    return c.SDL_CreateRenderer(window, name) orelse {
        log.err("Failed to SDL_CreateRenderer: {s}", .{c.SDL_GetError()});
        return error.SdlError;
    };
}

pub fn renderClear(renderer: *Renderer) error{SdlError}!void {
    if (!c.SDL_RenderClear(renderer)) {
        log.err("Failed to SDL_RenderClear: {s}", .{c.SDL_GetError()});
        return error.SdlError;
    }
}

pub fn renderPresent(renderer: *Renderer) error{SdlError}!void {
    if (!c.SDL_RenderPresent(renderer)) {
        log.err("Failed to SDL_RenderPresent: {s}", .{c.SDL_GetError()});
        return error.SdlError;
    }
}

pub fn setRenderDrawColor(renderer: *Renderer, r: u8, g: u8, b: u8, a: u8) error{SdlError}!void {
    if (!c.SDL_SetRenderDrawColor(renderer, r, g, b, a)) {
        log.err("Failed to SDL_SetRenderDrawColor: {s}", .{c.SDL_GetError()});
        return error.SdlError;
    }
}

pub fn renderFillRect(renderer: *Renderer, rect: Rect(f32)) error{SdlError}!void {
    if (!c.SDL_RenderFillRect(renderer, &.{
        .x = rect.pos.x,
        .y = rect.pos.y,
        .w = rect.size.x,
        .h = rect.size.y,
    })) {
        log.err("Failed to SDL_SetRenderDrawColor: {s}", .{c.SDL_GetError()});
        return error.SdlError;
    }
}

pub fn getRendererFromTexture(texture: *Texture) !*Renderer {
    return c.SDL_GetRendererFromTexture(texture) orelse {
        log.err("Failed to SDL_GetRendererFromTexture: {s}", .{c.SDL_GetError()});
        return error.SdlError;
    };
}

pub fn getRenderWindow(renderer: *Renderer) error{SdlError}!*Window {
    return c.SDL_GetRenderWindow(renderer) orelse {
        log.err("Failed to SDL_GetRenderWindow: {s}", .{c.SDL_GetError()});
        return error.SdlError;
    };
}

pub fn renderTexture(
    renderer: *Renderer,
    texture: *Texture,
    srcrect: ?Rect(f32),
    dstrect: ?Rect(f32),
) !void {
    if (!c.SDL_RenderTexture(
        renderer,
        texture,
        if (srcrect) |r| &c.SDL_FRect{ .x = r.pos.x, .y = r.pos.y, .w = r.size.x, .h = r.size.y } else null,
        if (dstrect) |r| &c.SDL_FRect{ .x = r.pos.x, .y = r.pos.y, .w = r.size.x, .h = r.size.y } else null,
    )) {
        log.err("Failed to SDL_RenderTexture: {s}", .{c.SDL_GetError()});
        return error.SdlError;
    }
}

pub fn renderLine(renderer: *Renderer, p1: Vec2(f32), p2: Vec2(f32)) error{SdlError}!void {
    if (!c.SDL_RenderLine(renderer, p1.x, p1.y, p2.x, p2.y)) {
        log.err("Failed to SDL_RenderLine: {s}", .{c.SDL_GetError()});
        return error.SdlError;
    }
}

pub const Flip = enum { none, horizontal, vertical };

pub fn renderTextureRotated(
    renderer: *Renderer,
    texture: *Texture,
    srcrect: ?Rect(f32),
    dstrect: ?Rect(f32),
    angle: f64,
    center: ?Vec2(f32),
    flip: Flip,
) !void {
    if (!c.SDL_RenderTextureRotated(
        renderer,
        texture,
        if (srcrect) |r| &.{ .x = r.pos.x, .y = r.pos.y, .w = r.size.x, .h = r.size.y } else null,
        if (dstrect) |r| &.{ .x = r.pos.x, .y = r.pos.y, .w = r.size.x, .h = r.size.y } else null,
        angle,
        if (center) |c_vec| &.{ .x = c_vec.x, .y = c_vec.y } else null,
        switch (flip) {
            .none => c.SDL_FLIP_NONE,
            .horizontal => c.SDL_FLIP_HORIZONTAL,
            .vertical => c.SDL_FLIP_VERTICAL,
        },
    )) {
        log.err("Failed to SDL_RenderTexture: {s}", .{c.SDL_GetError()});
        return error.SdlError;
    }
}

pub fn loadTexture(renderer: *Renderer, file: [*:0]const u8) error{SdlError}!*Texture {
    return c.IMG_LoadTexture(renderer, file) orelse {
        log.err("Failed to IMG_LoadTexture: {s}", .{c.SDL_GetError()});
        return error.SdlError;
    };
}

pub fn loadTextureIo(renderer: *Renderer, src: *IoStream, closeio: bool) error{SdlError}!*Texture {
    return c.IMG_LoadTexture_IO(renderer, src, closeio) orelse {
        log.err("Failed to IMG_LoadTexture_IO: {s}", .{c.SDL_GetError()});
        return error.SdlError;
    };
}

pub const ScaleMode = enum { nearest, linear };

pub fn setTextureScaleMode(texture: *Texture, scale_mode: ScaleMode) error{SdlError}!void {
    const c_scale_mode = switch (scale_mode) {
        .nearest => c.SDL_SCALEMODE_NEAREST,
        .linear => c.SDL_SCALEMODE_LINEAR,
    };
    if (!c.SDL_SetTextureScaleMode(texture, c_scale_mode)) {
        log.err("Failed to SDL_SetTextureScaleMode: {s}", .{c.SDL_GetError()});
        return error.SdlError;
    }
}

pub fn getTextureSize(texture: *Texture) error{SdlError}!Vec2(f32) {
    var width: f32 = 0;
    var height: f32 = 0;
    if (!c.SDL_GetTextureSize(texture, &width, &height)) {
        log.err("Failed to SDL_SetTextureScaleMode: {s}", .{c.SDL_GetError()});
        return error.SdlError;
    }
    return Vec2(f32).init(width, height);
}

pub fn hasRectIntersectionFloat(a: Rect(f32), b: Rect(f32)) bool {
    return c.SDL_HasRectIntersectionFloat(
        &.{ .x = a.pos.x, .y = a.pos.y, .w = a.size.x, .h = a.size.y },
        &.{ .x = b.pos.x, .y = b.pos.y, .w = b.size.x, .h = b.size.y },
    );
}

pub fn createTextureFromSurface(renderer: *Renderer, surface: *Surface) error{SdlError}!*Texture {
    return c.SDL_CreateTextureFromSurface(renderer, surface) orelse {
        log.err("Failed to SDL_CreateTextureFromSurface: {s}", .{c.SDL_GetError()});
        return error.SdlError;
    };
}

pub fn ioFromConstMem(mem: []const u8) error{SdlError}!*IoStream {
    return c.SDL_IOFromConstMem(mem.ptr, mem.len) orelse {
        log.err("Failed to SDL_IOFromConstMem: {s}", .{c.SDL_GetError()});
        return error.SdlError;
    };
}

pub fn ioFromFile(path: [*:0]const u8, mode: [*:0]const u8) error{SdlError}!*IoStream {
    return c.SDL_IOFromFile(path, mode) orelse {
        log.err("Failed to SDL_IOFromFile: {s}", .{c.SDL_GetError()});
        return error.SdlError;
    };
}

pub fn closeIO(io_stream: *IoStream) error{SdlError}!void {
    if (!c.SDL_CloseIO(io_stream)) {
        log.err("Failed to SDL_CloseIO: {s}", .{c.SDL_GetError()});
        return error.SdlError;
    }
}

pub fn getWindowSize(window: *Window) error{SdlError}!Vec2(u32) {
    var window_size: Vec2(c_int) = undefined;
    if (!c.SDL_GetWindowSize(window, &window_size.x, &window_size.y)) {
        log.err("Failed to SDL_GetWindowSize: {s}", .{c.SDL_GetError()});
        return error.SdlError;
    }
    return window_size.intCast(u32);
}

pub fn pollEvent() ?Event {
    var event: Event = undefined;
    if (c.SDL_PollEvent(&event)) return event else return null;
}

pub fn setMemoryFunctions(
    malloc: ?*const fn (usize) callconv(.c) ?*anyopaque,
    calloc: ?*const fn (usize, usize) callconv(.c) ?*anyopaque,
    realloc: ?*const fn (?*anyopaque, usize) callconv(.c) ?*anyopaque,
    free: ?*const fn (?*anyopaque) callconv(.c) void,
) error{SdlError}!void {
    if (!c.SDL_SetMemoryFunctions(malloc, calloc, realloc, free)) {
        log.err("Failed to SDL_SetMemoryFunctions: {s}", .{c.SDL_GetError()});
        return error.SdlError;
    }
}

var allocator: ?Allocator = null;

pub fn setAllocator(a: Allocator) error{SdlError}!void {
    allocator = a;
    const Functions = struct {
        fn malloc(size: usize) callconv(.c) ?*anyopaque {
            if (size == 0) return null;
            const mem_size_with_len: usize = @sizeOf(usize) + size;
            const mem_with_len: []u8 = allocator.?.alloc(u8, mem_size_with_len) catch return null;
            @as(*usize, @ptrCast(@alignCast(mem_with_len.ptr))).* = size;
            return mem_with_len.ptr + @sizeOf(usize);
        }

        fn calloc(nmemb: usize, size: usize) callconv(.c) ?*anyopaque {
            const mem_size: usize = nmemb *% size;
            if (mem_size == 0) return null;
            const mem_size_with_len: usize = @sizeOf(usize) + mem_size;
            const mem_with_len: []u8 = allocator.?.alloc(u8, mem_size_with_len) catch return null;
            @as(*usize, @ptrCast(@alignCast(mem_with_len.ptr))).* = mem_size;
            const mem: []u8 = mem_with_len[@sizeOf(usize)..];
            @memset(mem, 0);
            return mem.ptr;
        }

        fn realloc(ptr: ?*anyopaque, new_size: usize) callconv(.c) ?*anyopaque {
            const p: *anyopaque = if (ptr) |p| p else {
                const mem_size_with_len: usize = @sizeOf(usize) + new_size;
                const mem_with_len: []u8 = allocator.?.alloc(u8, mem_size_with_len) catch return null;
                @as(*usize, @ptrCast(@alignCast(mem_with_len.ptr))).* = new_size;
                return mem_with_len.ptr + @sizeOf(usize);
            };
            const old_ptr_with_len: [*]u8 = @as([*]u8, @ptrCast(p)) - @sizeOf(usize);
            const old_mem_len: usize = @as(*usize, @ptrCast(@alignCast(old_ptr_with_len))).*;
            const old_mem_with_len: []u8 = old_ptr_with_len[0 .. @sizeOf(usize) + old_mem_len];
            if (new_size == 0) {
                allocator.?.free(old_mem_with_len);
                return null;
            }
            const new_mem_with_len: []u8 = allocator.?.realloc(old_mem_with_len, @sizeOf(usize) + new_size) catch return null;
            @as(*usize, @ptrCast(@alignCast(new_mem_with_len.ptr))).* = new_size;
            const new_mem: []u8 = new_mem_with_len[@sizeOf(usize)..];
            return new_mem.ptr;
        }

        fn free(ptr: ?*anyopaque) callconv(.c) void {
            const p: *anyopaque = if (ptr) |p| p else return;
            const ptr_with_len: [*]u8 = @as([*]u8, @ptrCast(p)) - @sizeOf(usize);
            const mem_len: usize = @as(*usize, @ptrCast(@alignCast(ptr_with_len))).*;
            const mem_with_len: []u8 = ptr_with_len[0 .. @sizeOf(usize) + mem_len];
            allocator.?.free(mem_with_len);
        }
    };

    try setMemoryFunctions(Functions.malloc, Functions.calloc, Functions.realloc, Functions.free);
}

pub const ttf = struct {
    pub const Font = c.TTF_Font;

    pub const closeFont = c.TTF_CloseFont;
    pub const quit = c.TTF_Quit;

    pub fn init() error{SdlError}!void {
        if (!c.TTF_Init()) {
            log.err("Failed to TTF_Init: {s}", .{c.SDL_GetError()});
            return error.SdlError;
        }
    }

    pub fn openFont(file: [*:0]const u8, ptsize: f32) error{SdlError}!*Font {
        return c.TTF_OpenFont(file, ptsize) orelse {
            log.err("Failed to TTF_OpenFont: {s}", .{c.SDL_GetError()});
            return error.SdlError;
        };
    }

    pub fn openFontIo(src: *IoStream, closeio: bool, ptsize: f32) error{SdlError}!*Font {
        return c.TTF_OpenFontIO(src, closeio, ptsize) orelse {
            log.err("Failed to TTF_OpenFontIO: {s}", .{c.SDL_GetError()});
            return error.SdlError;
        };
    }

    pub fn renderTextBlended(font: *Font, text: []const u8, fg: Color) error{SdlError}!*Surface {
        return c.TTF_RenderText_Blended(font, text.ptr, text.len, .{ .r = fg.r, .g = fg.g, .b = fg.b, .a = fg.a }) orelse {
            log.err("Failed to TTF_RenderText_Blended: {s}", .{c.SDL_GetError()});
            return error.SdlError;
        };
    }
};
