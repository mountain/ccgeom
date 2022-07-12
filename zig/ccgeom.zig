const std = @import("std");
const zmath = @import("zmath.zig");

const debug = std.debug;
const assert = debug.assert;
const testing = std.testing;
const mem = std.mem;
const Allocator = mem.Allocator;

const StringArrayHashMap = std.array_hash_map.StringArrayHashMap;
const ArrayList = std.ArrayList;


var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();


const HalfEdge = struct {
    next: *HalfEdge,
    prev: *HalfEdge,
    source: *Vertex,
    target: *Vertex,
    edge: *Edge,
    face: *Face,
};

const Vertex = struct {
    halfedge_1st: *HalfEdge,
};

const Edge = struct {
    halfedge_1st: *HalfEdge,
    halfedge_2nd: *HalfEdge,
};

const Face = struct {
    halfedge_1st: *HalfEdge,
};

const Position = zmath.Vec; // (x, y, z, 0)
const Vector = zmath.Vec;   // (u_x, u_y, u_z, length) where ux^2 + uy^2 + uz^2 = 1


pub fn Surface(
    comptime V: type, // vertex type
    comptime E: type, // edge type
    comptime F: type, // face type
    comptime H: type, // halfedge type
) type {
    return struct{
        alloc: Allocator,

        n_vertices: i64, n_edges: i64, n_faces: i64,

        chi: i64,
        genus: i64,

        positions: *[]Position,
        vectors: *[]Vector,

        vertices: *[]V,
        edges: *[]E,
        faces: *[]F,
        halfedges: *[]H,

        const Self = @This();

        /// Create a Surface instance which will use a specified allocator.
        pub fn init(alloc: Allocator, n_vertices: i64, n_edges: i64, n_faces: i64) Self {
            assert(n_vertices > 0);
            assert(n_edges > 0);
            assert(n_faces > 0);
            var chi: i64 = n_vertices - n_edges + n_faces;
            assert(@divTrunc(chi, 2) * 2 == chi);
            var genus: i64 = 1 - @divTrunc(chi, 2);
            return .{
                .alloc = alloc,
                .n_vertices = n_vertices,
                .n_edges = n_edges,
                .n_faces = n_faces,
                .chi = chi,
                .genus = genus,
                .positions = &(allocator.alloc(Position, @intCast(u32, n_vertices + n_edges + n_faces)) catch undefined),
                .vectors = &(allocator.alloc(Vector, @intCast(u32, 2 * n_edges + n_faces)) catch undefined),
                .vertices = &(allocator.alloc(V, @intCast(u32, n_vertices)) catch undefined),
                .edges = &(allocator.alloc(E, @intCast(u32, n_edges)) catch undefined),
                .faces = &(allocator.alloc(F, @intCast(u32, n_faces)) catch undefined),
                .halfedges = &(allocator.alloc(H, @intCast(u32, 2 * n_edges)) catch undefined),
            };
        }

        /// Frees the backing allocation and leaves the mesh in an undefined state.
        pub fn deinit(self: *Self) void {
            if(self.positions != undefined) {
                self.alloc.free(self.positions.*);
                self.positions = undefined;
            }
            if(self.vectors != undefined) {
                self.alloc.free(self.vectors.*);
                self.vectors = undefined;
            }
            if(self.vertices != undefined) {
                self.alloc.free(self.vertices.*);
                self.vertices = undefined;
            }
            if(self.edges != undefined) {
                self.alloc.free(self.edges.*);
                self.edges = undefined;
            }
            if(self.faces != undefined) {
                self.alloc.free(self.faces.*);
                self.faces = undefined;
            }
            if(self.halfedges != undefined) {
                self.alloc.free(self.halfedges.*);
                self.halfedges = undefined;
            }
            self.* = undefined;
        }
    };
}

pub fn UniversalCovering(
    comptime S: type, // surface type
) type {
    return struct{
        alloc: Allocator,
        base: S,
        covering: StringArrayHashMap(S),

        const Self = @This();

        /// Create an UniversalCovering instance which will use a specified allocator.
        pub fn init(alloc: Allocator, base: S) Self {
            return .{
                .alloc = alloc,
                .base = base,
                .covering = StringArrayHashMap(S).init(alloc),
            };
        }

        /// Frees the backing allocation and leaves the mesh in an undefined state.
        pub fn deinit(self: *Self) void {
            self.base.deinit();
            self.covering.deinit();
            self.* = undefined;
        }
    };
}


const SimpleSurface = Surface(Vertex, Edge, Face, HalfEdge);
const SimpleUniversalCovering = UniversalCovering(SimpleSurface);

var registry = ArrayList(SimpleUniversalCovering).init(allocator);

export fn surface(n_vertices: i64, n_edges: i64, n_faces: i64) u64 {
    var s = SimpleSurface.init(allocator, n_vertices, n_edges, n_faces);
    var uc = SimpleUniversalCovering.init(allocator, s);
    registry.append(uc) catch {};
    return registry.items.len - 1;
}

export fn vertice(sid: i64, idx: i64, x: f64, y: f64, z: f64) u64 {
    var s = SimpleSurface.init(allocator, n_vertices, n_edges, n_faces);
    var uc = SimpleUniversalCovering.init(allocator, s);
    registry.append(uc) catch {};
    return registry.items.len - 1;
}

test "mesh construction" {
    testing.except(surface(10, 10, 10) == 0);
    testing.except(surface(10, 10, 10) == 1);
    testing.except(surface(10, 10, 10) == 2);
}
