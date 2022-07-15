const std = @import("std");
const utl = @import("util.zig");
const zmath = @import("zmath.zig");

const debug = std.debug;
const assert = debug.assert;
const testing = std.testing;
const Allocator = std.mem.Allocator;

pub const HalfEdge = struct {
    id: u32,
    next: *HalfEdge,
    prev: *HalfEdge,
    source: *Vertice,
    target: *Vertice,
    edge: *Edge,
    face: *Face,
};

pub const Vertice = struct {
    id: u32,
    halfedge_1st: *HalfEdge,
};

pub const Edge = struct {
    id: u32,
    halfedge_1st: *HalfEdge,
    halfedge_2nd: *HalfEdge,
};

pub const Face = struct {
    id: u32,
    cw: *HalfEdge,
    ccw: *HalfEdge,
};

/// The mesh and its topological information
pub fn Mesh(
    comptime V: type, // vertice type
    comptime E: type, // edge type
    comptime F: type, // face type
    comptime H: type, // halfedge type
) type {
    return struct {
        alloc: Allocator,

        n_vertices: u32, n_edges: u32, n_faces: u32,

        chi: i32,
        genus: i32,

        vertices: []V,
        edges: []E,
        faces: []F,
        halfedges: []H,

        const Self = @This();

        /// Create a Mesh instance which will use a specified allocator.
        pub fn init(allocator: Allocator, n_vertices: u32, n_edges: u32, n_faces: u32) Self {
            assert(n_vertices > 0);
            assert(n_edges > 0);
            assert(n_faces > 0);
            var chi: i32 = @intCast(i32, n_vertices) - @intCast(i32, n_edges) + @intCast(i32, n_faces);
            assert(@divTrunc(chi, 2) * 2 == chi);
            var genus: i32 = 1 - @divTrunc(chi, 2);
            return .{
                .alloc = allocator,
                .n_vertices = n_vertices,
                .n_edges = n_edges,
                .n_faces = n_faces,
                .chi = chi,
                .genus = genus,
                .vertices = (allocator.alloc(V, @intCast(u32, n_vertices)) catch undefined),
                .edges = (allocator.alloc(E, @intCast(u32, n_edges)) catch undefined),
                .faces = (allocator.alloc(F, @intCast(u32, n_faces)) catch undefined),
                .halfedges = (allocator.alloc(H, @intCast(u32, 2 * n_edges)) catch undefined),
            };
        }

        /// Frees the backing allocation and leaves the mesh in an undefined state.
        pub fn deinit(self: *Self) void {
            self.alloc.free(self.vertices);
            self.vertices = undefined;
            self.alloc.free(self.edges);
            self.edges = undefined;
            self.alloc.free(self.faces);
            self.faces = undefined;
            self.alloc.free(self.halfedges);
            self.halfedges = undefined;
            self.* = undefined;
        }
    };
}
