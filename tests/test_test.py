# -*- coding: utf-8 -*-

import unittest

import ccgeom as ccg


class TestTest(unittest.TestCase):
    def test_tetrahedron(self):
        self.assertEqual(ccg.begin(), 1)
        self.assertEqual(ccg.build_surface(4, 6, 4), 1)
        self.assertEqual(ccg.build_vertice(1.0, 0.0, -0.707106), 1)
        self.assertEqual(ccg.build_vertice(-1.0, 0.0, -0.707106), 2)
        self.assertEqual(ccg.build_vertice(0.0, 1.0, 0.707106), 3)
        self.assertEqual(ccg.build_vertice(0.0, -1.0, 0.707106), 4)
        self.assertEqual(ccg.build_face3(1, 2, 3), 1)
        self.assertEqual(ccg.build_face3(1, 3, 4), 2)
        self.assertEqual(ccg.build_face3(1, 4, 2), 3)
        self.assertEqual(ccg.build_face3(2, 3, 4), 4)
        self.assertEqual(ccg.commit(), 1)
