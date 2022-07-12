# -*- coding: utf-8 -*-

import unittest

import ccgeom as ccg


class TestTest(unittest.TestCase):
    def test_test(self):
        idx = ccg.surface(8, 12, 6)
        print(idx)
        self.assertEqual(idx, 0)
