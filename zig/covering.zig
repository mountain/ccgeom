const std = @import("std");
const msh = @import("mesh.zig");
const sfc = @import("surface.zig");

const debug = std.debug;
const assert = debug.assert;
const testing = std.testing;
const Allocator = std.mem.Allocator;
const StringArrayHashMap = std.array_hash_map.StringArrayHashMap;

/// The tilling cell in the UCS of the surface
/// The UCS is adapted to a half plane model of H^2
pub fn Cell(
    comptime M: type, // mesh type
) type {
    return struct{
        mesh: *M,
        positions: []f32,
        vectors: []f32,

        const Self = @This();

        /// Create a Surface instance which will use a specified allocator.
        pub fn init(allocator: Allocator, mesh: msh.Mesh, n_vertices: u32, n_edges: u32, n_faces: u32) Self {
            assert(n_vertices > 0);
            assert(n_edges > 0);
            assert(n_faces > 0);
            return .{
                .mesh = &mesh,
                .positions = (allocator.alloc(f32, @intCast(u32, 2 * (n_vertices + n_edges + n_faces))) catch undefined),
                .vectors = (allocator.alloc(f32, @intCast(u32, 2 * (2 * n_edges + n_faces))) catch undefined),
            };
        }

        /// Frees the backing allocation and leaves the mesh in an undefined state.
        pub fn deinit(self: *Self) void {
            if(self.positions != undefined) {
                self.alloc.free(self.positions);
                self.positions = undefined;
            }
            if(self.vectors != undefined) {
                self.alloc.free(self.vectors);
                self.vectors = undefined;
            }
            self.mesh = undefined;
            self.* = undefined;
        }
    };
}

pub fn UniversalCovering(
    comptime M: type, // mesh type
    comptime S: type, // surface type
    comptime C: type, // cell type
) type {
    const Dict = StringArrayHashMap(C);
    return struct{
        mesh: M,
        base: S,
        covering: Dict,

        const Self = @This();

        /// Create an UniversalCovering instance which will use a specified allocator.
        pub fn init(allocator: Allocator, n_vertices: u32, n_edges: u32, n_faces: u32) Self {
            var m = M.init(allocator, n_vertices, n_edges, n_faces);
            return .{
                .mesh = m,
                .base = S.init(allocator, m, n_vertices, n_edges, n_faces),
                .covering = Dict.init(allocator),
            };
        }

        /// Frees the backing allocation and leaves the mesh in an undefined state.
        pub fn deinit(self: *Self) void {
            Dict.deinit(&(self.*.covering));
            S.deinit(&(self.*.base));
            M.deinit(&(self.*.mesh));
            self.* = undefined;
        }
    };
}
