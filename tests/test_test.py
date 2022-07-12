# -*- coding: utf-8 -*-

import unittest

import ccgeom as ccg


class TestTest(unittest.TestCase):
    def test_surface(self):
        self.assertEqual(ccg.surface(4, 6, 4), 0)
        self.assertEqual(ccg.surface(8, 12, 6), 1)
        self.assertEqual(ccg.surface(6, 12, 8), 2)
        self.assertEqual(ccg.surface(20, 30, 12), 3)
        self.assertEqual(ccg.surface(12, 30, 20), 4)

    def test_vertice_err(self):
        self.assertEqual(ccg.vertice(0, 0, 0.0, 0.0, 0.0), 1)
        self.assertEqual(ccg.vertice(0, 1, 1.0, 0.0, 0.0), 1)
        self.assertEqual(ccg.vertice(0, 2, 0.0, 1.0, 0.0), 1)
        self.assertEqual(ccg.vertice(0, 3, 1.0, 1.0, 0.0), 1)
        self.assertEqual(ccg.vertice(0, 4, 0.0, 0.0, 1.0), -1)

    def test_vertice_ok(self):
        self.assertEqual(ccg.vertice(1, 0, 0.0, 0.0, 0.0), 1)
        self.assertEqual(ccg.vertice(1, 1, 1.0, 0.0, 0.0), 1)
        self.assertEqual(ccg.vertice(1, 2, 0.0, 1.0, 0.0), 1)
        self.assertEqual(ccg.vertice(1, 3, 1.0, 1.0, 0.0), 1)
        self.assertEqual(ccg.vertice(1, 4, 0.0, 0.0, 1.0), 1)
        self.assertEqual(ccg.vertice(1, 5, 1.0, 0.0, 1.0), 1)
        self.assertEqual(ccg.vertice(1, 6, 0.0, 1.0, 1.0), 1)
        self.assertEqual(ccg.vertice(1, 7, 1.0, 1.0, 1.0), 1)
