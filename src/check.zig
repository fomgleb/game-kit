const std = @import("std");
const root = @import("root.zig");

pub fn main() void {
    refAllDeclsRecursive(root);
}

pub fn refAllDeclsRecursive(comptime T: type) void {
    const declarations = comptime std.meta.declarations(T);
    if (declarations.len >= 2000) return;

    inline for (declarations) |decl| {
        const root_field = @field(T, decl.name);
        if (@TypeOf(root_field) == type) {
            switch (@typeInfo(root_field)) {
                .@"struct", .@"enum", .@"union", .@"opaque" => refAllDeclsRecursive(root_field),
                else => {},
            }
        } else {
            refFunction(root_field);
            // @compileLog(std.fmt.comptimePrint("the fn name: {s}", .{decl.name}));
        }
    }
}

fn refFunction(comptime func: anytype) void {
    const FuncType = @TypeOf(func);
    const func_info = @typeInfo(FuncType).@"fn";

    if (func_info.params.len > 0) {
        comptime var args: std.meta.ArgsTuple(FuncType) = undefined;

        // Fill in comptime parameters with dummy values
        inline for (func_info.params, 0..) |param, i| {
            // Handle comptime parameters based on their type
            if (param.type) |param_type| {
                switch (@typeInfo(param_type)) {
                    .pointer => |ptr_info| {
                        if (ptr_info.size == .slice and ptr_info.child == u8) {
                            // String literals - use empty string
                            args[i] = "asset_loader.zig";
                        } else {
                            // Other pointer types - use undefined
                            args[i] = undefined;
                        }
                    },
                    .type => {
                        // Type parameters - use u8 as a default
                        args[i] = u8;
                    },
                    else => {
                        // Other comptime types - use undefined
                        args[i] = undefined;
                    },
                }
            } else {
                args[i] = undefined;
            }
        }

        // Handle the function call based on return type
        if (func_info.return_type) |ret_type| {
            const ret_info = @typeInfo(ret_type);
            if (ret_info == .error_union) {
                _ = @call(.auto, func, args) catch {};
            } else {
                _ = @call(.auto, func, args);
            }
        } else {
            @call(.auto, func, args);
        }
    } else {
        // Handle parameterless functions
        if (func_info.return_type) |ret_type| {
            const ret_info = @typeInfo(ret_type);
            if (ret_info == .error_union) {
                _ = @call(.auto, func, .{}) catch {};
            } else {
                _ = @call(.auto, func, .{});
            }
        } else {
            @call(.auto, func, .{});
        }
    }
}
