const std = @import("std");
const bld = @import("builder.zig");

/// Conceptualy, we manage a lot of surfaces here.
/// But in the implementation, we manage many universal covering spaces (USCs) instead.
/// Each USC is collection of a shared mesh, a base surface in Euclidean space R^3,
/// and many tilling cells in a Hyperbolic plane(H^2) which is described by the upper-half plane model.

const debug = std.debug;
const assert = debug.assert;
const testing = std.testing;


/// begin of a session to create a ucs and the related surface
export fn begin() u32 {
    return bld.begin();
}

/// commit of the operations in the session to create a ucs and the related surface
export fn commit() u32 {
    return bld.commit();
}

/// commit of the operations in the session to create a ucs and the related surface
export fn rollback() u32 {
    return bld.rollback();
}

export fn build_surface(n_vertices: u32, n_edges: u32, n_faces: u32) u32 {
    return bld.surface(n_vertices, n_edges, n_faces);
}

export fn build_vertice(x: f64, y: f64, z: f64) u32 {
    return bld.vertice(x, y, z);
}

export fn build_halfedge(source: u32, target: u32, prev: u32, next: u32) u32 {
    return bld.halfedge(source, target, prev, next);
}

export fn build_edge(source: u32, target: u32) u32 {
    return bld.edge(source, target);
}

export fn build_face3(vert1: u32, vert2: u32, vert3: u32) u32 {
   return bld.face3(vert1, vert2, vert3);
}

export fn build_face4(vert1: u32, vert2: u32, vert3: u32, vert4: u32) u32 {
   return bld.face4(vert1, vert2, vert3, vert4);
}

export fn build_face5(vert1: u32, vert2: u32, vert3: u32, vert4: u32, vert5: u32) u32 {
    return bld.face5(vert1, vert2, vert3, vert4, vert5);
}

export fn build_face6(vert1: u32, vert2: u32, vert3: u32, vert4: u32, vert5: u32, vert6: u32) u32 {
    return bld.face6(vert1, vert2, vert3, vert4, vert5, vert6);
}

export fn build_face7(vert1: u32, vert2: u32, vert3: u32, vert4: u32, vert5: u32, vert6: u32, vert7: u32) u32 {
    return bld.face7(vert1, vert2, vert3, vert4, vert5, vert6, vert7);
}

export fn build_face8(vert1: u32, vert2: u32, vert3: u32, vert4: u32, vert5: u32, vert6: u32, vert7: u32, vert8: u32) u32 {
    return bld.face8(vert1, vert2, vert3, vert4, vert5, vert6, vert7, vert8);
}

export fn build_face9(vert1: u32, vert2: u32, vert3: u32, vert4: u32, vert5: u32, vert6: u32, vert7: u32, vert8: u32, vert9: u32) u32 {
    return bld.face9(vert1, vert2, vert3, vert4, vert5, vert6, vert7, vert8, vert9);
}

export fn build_face(num: u32, vert1: u32, vert2: u32, vert3: u32, vert4: u32, vert5: u32,
                         vert6: u32, vert7: u32, vert8: u32, vert9: u32, vert10: u32, vert11: u32, vert12: u32) u32 {
    return bld.face(num, vert1, vert2, vert3, vert4, vert5, vert6, vert7, vert8, vert9, vert10, vert11, vert12);
}

test "tetrahedron construction" {
    try testing.expectEqual(begin(), 1);
    try testing.expectEqual(build_surface(4, 6, 4), 1);
    try testing.expectEqual(build_vertice(1.0, 0.0, -0.707106), 1);
    try testing.expectEqual(build_vertice(-1.0, 0.0, -0.707106), 2);
    try testing.expectEqual(build_vertice(0.0, 1.0, 0.707106), 3);
    try testing.expectEqual(build_vertice(0.0, -1.0, 0.707106), 4);
    try testing.expectEqual(build_face3(1, 2, 3), 1);
    try testing.expectEqual(build_face3(1, 3, 4), 2);
    try testing.expectEqual(build_face3(1, 4, 2), 3);
    try testing.expectEqual(build_face3(2, 3, 4), 4);
    try testing.expectEqual(commit(), 1);
}



