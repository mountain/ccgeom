const std = @import("std");
const msh = @import("mesh.zig");

const debug = std.debug;
const assert = debug.assert;
const testing = std.testing;
const Allocator = std.mem.Allocator;


/// The surface and its embedding information
pub fn Surface(
    comptime M: type, // mesh type
) type {
    return struct {
        alloc: Allocator,
        mesh: M,
        positions: []f32,
        vectors: []f32,

        const Self = @This();

        /// Create a Surface instance which will use a specified allocator.
        pub fn init(allocator: Allocator, mesh: M, n_vertices: u32, n_edges: u32, n_faces: u32) Self {
            assert(n_vertices > 0);
            assert(n_edges > 0);
            assert(n_faces > 0);
            return .{
                .alloc = allocator,
                .mesh = mesh,
                .positions = (allocator.alloc(f32, @intCast(u32, 4 * (n_vertices + n_edges + n_faces))) catch undefined),
                .vectors = (allocator.alloc(f32, @intCast(u32, 4 * (2 * n_edges + n_faces))) catch undefined),
            };
        }

        /// Frees the backing allocation and leaves the mesh in an undefined state.
        pub fn deinit(self: *Self) void {
            self.alloc.free(self.positions);
            self.positions = undefined;
            self.alloc.free(self.vectors);
            self.vectors = undefined;
            self.mesh = undefined;
            self.* = undefined;
        }
    };
}
