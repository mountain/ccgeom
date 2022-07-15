const std = @import("std");
const utl = @import("util.zig");
const mth = @import("zmath.zig");
const msh = @import("mesh.zig");
const sfc = @import("surface.zig");
const cvr = @import("covering.zig");

/// Conceptualy, we manage a lot of surfaces here.
/// But in the implementation, we manage many universal covering spaces (USCs) instead.
/// Each USC is collection of a shared mesh, a base surface in Euclidean space R^3,
/// and many tilling cells in a Hyperbolic plane(H^2) which is described by the upper-half plane model.

const debug = std.debug;
const assert = debug.assert;
const testing = std.testing;

const ArrayList = std.ArrayList;

const SimpleMesh = msh.Mesh(msh.Vertice, msh.Edge, msh.Face, msh.HalfEdge);
const SimpleSurface = sfc.Surface(SimpleMesh);
const SimpleCell = cvr.Cell(SimpleMesh);
const SimpleUniversalCovering = cvr.UniversalCovering(SimpleMesh, SimpleSurface, SimpleCell);

/// a global registry of all surfaces and universal covering spaces we have created
/// every surface is paired with a universal covering space
var registry = ArrayList(SimpleUniversalCovering).init(utl.allocator);

/// implicitly global-managed ids
/// every surface is paired with a unique id, all id is one-based numbers counting from 1 to n,
/// and we use zero as a sentinel to represent an invalid singal from api.
/// since a surface is keeped in a UCS, sid (the index of the surface in the registry) is the same as
/// uid (the index of UCS in the registry)

var vid: u32 = 1; // vertice id, in a surface-scope
var eid: u32 = 1; // edge id, in a surface-scope
var hid: u32 = 1; // halfedge id, in a surface-scope
var fid: u32 = 1; // face id, in a surface-scope
var cid: u32 = 1; // cell id, in a surface-scope
var sid: u32 = 1; // surface id, same as universal covering space id, surface and ucs are paired
var flag: bool = false; // flag to indicate whether we have created a new surface

/// begin of a session to create a ucs and the related surface
pub fn begin() u32 {
    vid = 1;
    eid = 1;
    hid = 1;
    fid = 1;
    cid = 1;
    flag = false;
    return  sid;
}

/// commit of the operations in the session to create a ucs and the related surface
pub fn commit() u32 {
    if (sid != registry.items.len) return 0;
    const uc = registry.items[@intCast(u32, sid - 1)];
    const mesh = uc.mesh;
    if (vid != mesh.n_vertices + 1) return 0;
    if (eid != mesh.n_edges + 1) return 0;
    if (fid != mesh.n_faces + 1) return 0;
    flag = true;
    sid = sid + 1;
    return sid - 1;
}

/// commit of the operations in the session to create a ucs and the related surface
pub fn rollback() u32 {
    if (sid != registry.items.len) return 0;
    if (flag) return 0;
    var uc = registry.popOrNull() orelse return 0;
    SimpleUniversalCovering.deinit(&uc);
    sid = sid - 1;
    return sid + 1;
}

pub fn surface(n_vertices: u32, n_edges: u32, n_faces: u32) u32 {
    registry.append(SimpleUniversalCovering.init(utl.allocator, n_vertices, n_edges, n_faces)) catch {};
    return sid;
}

pub fn vertice(x: f64, y: f64, z: f64) u32 {
    if (sid > registry.items.len) return 0;
    const uc = registry.items[@intCast(u32, sid - 1)];
    const m = uc.mesh;
    const s = uc.base;
    if (vid > m.n_vertices) return 0;

    var a: f32 = @floatCast(f32, x);
    var b: f32 = @floatCast(f32, y);
    var c: f32 = @floatCast(f32, z);
    var pos: usize = @intCast(u32, 4 * (vid - 1));
    mth.store(s.positions[pos..], mth.loadArr3([3]f32{a, b, c}), 4);

    vid = vid + 1;
    return vid - 1;
}

pub fn halfedge(source: u32, target: u32, prev: u32, next: u32) u32 {
    if (sid > registry.items.len) return 0;
    const uc = registry.items[@intCast(u32, sid - 1)];
    const m = uc.mesh;
    if (eid > m.n_edges) return 0;

    var he = m.halfedges[hid - 1];
    he.face = &(m.faces[fid - 1]);
    he.edge = &(m.edges[eid - 1]);
    he.source = &(m.vertices[source - 1]);
    he.target = &(m.vertices[target - 1]);
    he.prev = &(m.halfedges[prev - 1]);
    he.next = &(m.halfedges[next - 1]);

    hid = hid + 1;
    return hid - 1;
}

pub fn edge(source: u32, target: u32) u32 {
    if (sid > registry.items.len) return 0;
    const uc = registry.items[@intCast(u32, sid - 1)];
    const m = uc.mesh;
    const s = uc.base;
    if (eid > m.n_edges) return 0;

    var pos_begin: usize = @intCast(u32, 4 * (source + m.n_vertices - 1));
    var pos_end: usize = @intCast(u32, 4 * (target + m.n_vertices - 1));
    var pnt_begin = mth.load(s.positions[pos_begin..], mth.F32x4, 4);
    var pnt_end = mth.load(s.positions[pos_end..], mth.F32x4, 4);
    var pnt_mid = mth.lerp(pnt_begin, pnt_end, 0.5);

    var pos: usize = @intCast(u32, 4 * (eid + m.n_vertices - 1));
    mth.store(s.positions[pos..], pnt_mid, 4);

    var e = m.edges[eid - 1];
    e.halfedge_1st = &(m.halfedges[2 * eid - 2]);
    e.halfedge_2nd = &(m.halfedges[2 * eid - 1]);

    eid = eid + 1;
    return eid - 1;
}

pub fn face3(vert1: u32, vert2: u32, vert3: u32) u32 {
   return face(3, vert1, vert2, vert3, 0, 0, 0, 0, 0, 0, 0, 0, 0);
}

pub fn face4(vert1: u32, vert2: u32, vert3: u32, vert4: u32) u32 {
   return face(4, vert1, vert2, vert3, vert4, 0, 0, 0, 0, 0, 0, 0, 0);
}

pub fn face5(vert1: u32, vert2: u32, vert3: u32, vert4: u32, vert5: u32) u32 {
    return face(5, vert1, vert2, vert3, vert4, vert5, 0, 0, 0, 0, 0, 0, 0);
}

pub fn face6(vert1: u32, vert2: u32, vert3: u32, vert4: u32, vert5: u32, vert6: u32) u32 {
    return face(6, vert1, vert2, vert3, vert4, vert5, vert6, 0, 0, 0, 0, 0, 0);
}

pub fn face7(vert1: u32, vert2: u32, vert3: u32, vert4: u32, vert5: u32, vert6: u32, vert7: u32) u32 {
    return face(7, vert1, vert2, vert3, vert4, vert5, vert6, vert7, 0, 0, 0, 0, 0);
}

pub fn face8(vert1: u32, vert2: u32, vert3: u32, vert4: u32, vert5: u32, vert6: u32, vert7: u32, vert8: u32) u32 {
    return face(8, vert1, vert2, vert3, vert4, vert5, vert6, vert7, vert8, 0, 0, 0, 0);
}

pub fn face9(vert1: u32, vert2: u32, vert3: u32, vert4: u32, vert5: u32, vert6: u32, vert7: u32, vert8: u32, vert9: u32) u32 {
    return face(9, vert1, vert2, vert3, vert4, vert5, vert6, vert7, vert8, vert9, 0, 0, 0);
}

pub fn face(num: u32, vert1: u32, vert2: u32, vert3: u32, vert4: u32, vert5: u32,
                         vert6: u32, vert7: u32, vert8: u32, vert9: u32, vert10: u32, vert11: u32, vert12: u32) u32 {
    if (sid > registry.items.len) return 0;
    const uc = registry.items[@intCast(u32, sid - 1)];
    const m = uc.mesh;
    if (fid > m.n_faces) return 0;

    var i: u32 = 0;
    var vids: [12]u32 = [12]u32{vert1, vert2, vert3, vert4, vert5, vert6, vert7, vert8, vert9, vert10, vert11, vert12};
    if (num < 3) return 0;
    if (num >= 12) return 0;
    while (i < num) : (i += 1) {
        if (vids[i] > m.n_vertices) return 0;
        // co-planar check
    }

    i = 0;
    var eidx: u32 = 0;
    while (i < num) : (i += 1) {
        eidx = edge(vids[i], vids[(i + 1) % num]);
    }

    i = 0;
    var hidx: u32 = 0;
    while (i < num) : (i += 1) {
        hidx = halfedge(vids[(i + num - 1) % num], vids[i], 1, 2); // TODO
        hidx = halfedge(vids[i], vids[(i + 1) % num], 1, 2); // TODO
    }

    fid = fid + 1;
    return fid - 1;
}

test "tetrahedron construction" {
    try testing.expectEqual(begin(), 2);
    try testing.expectEqual(surface(4, 6, 4), 2);
    try testing.expectEqual(vertice(1.0, 0.0, -0.707106), 1);
    try testing.expectEqual(vertice(-1.0, 0.0, -0.707106), 2);
    try testing.expectEqual(vertice(0.0, 1.0, 0.707106), 3);
    try testing.expectEqual(vertice(0.0, -1.0, 0.707106), 4);
    try testing.expectEqual(face3(1, 2, 3), 1);
    try testing.expectEqual(face3(1, 3, 4), 2);
    try testing.expectEqual(face3(1, 4, 2), 3);
    try testing.expectEqual(face3(2, 3, 4), 4);
    try testing.expectEqual(commit(), 2);
}
