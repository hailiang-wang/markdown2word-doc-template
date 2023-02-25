#!/usr/bin/env python
# -*- coding: utf-8 -*-
# ===============================================================================
#
# Copyright (c) 2020 <> All Rights Reserved
#
#
# File: /c/Users/Administrator/git/markdown2word-doc-template/scripts/py/count_words.py
# Author: Hai Liang Wang
# Date: 2023-02-25:12:13:57
#
# ===============================================================================

"""
   
"""
import jieba.posseg as pseg
import unittest
from copy import deepcopy
__copyright__ = "Copyright (c) 2020 . All Rights Reserved"
__author__ = "Hai Liang Wang"
__date__ = "2023-02-25:12:13:57"

import os
import sys
curdir = os.path.dirname(os.path.abspath(__file__))
sys.path.append(curdir)

if sys.version_info[0] < 3:
    raise RuntimeError("Must be using Python 3")
else:
    unicode = str


ENVIRON = os.environ.copy()
MD_INDEX_FILEPATH = ENVIRON.get("MD_INDEX_FILEPATH", None)


def format_number(num):
    """
    https://stackoverflow.com/questions/579310/formatting-long-numbers-as-strings
    """
    num = float('{:.3g}'.format(num))
    magnitude = 0
    while abs(num) >= 1000:
        magnitude += 1
        num /= 1000.0
    return '{}{}'.format('{:f}'.format(num).rstrip('0').rstrip('.'), ['', 'K', 'M', 'B', 'T'][magnitude])


"""
Checks
"""

if MD_INDEX_FILEPATH is None or not os.path.exists(MD_INDEX_FILEPATH):
    print("MD_INDEX_FILEPATH=", MD_INDEX_FILEPATH)
    raise RuntimeError("MD_INDEX_FILEPATH not defined or file not found.")

'''
preload of dict, print log
'''
ws = pseg.cut("春天在哪里")
[x for x in ws]


def get_len_hanz(txt):
    '''
    统计中文长度
    '''
    total = 0

    txt = txt.strip()
    if not txt:
        return 0

    words = pseg.cut(txt)
    # print(list(words))
    for word, flag in list(words):
        # print(word, "-->", flag)
        # print(word, flag)
        if flag.startswith("x"):
            continue
        elif flag.startswith("eng"):
            # 英文，按照一个词统计
            total = total + 1
            # print(word, "ENG")
        else:
            # 有效字符：中文
            # print(word, len(word))
            # print(word)
            total = total + len(word.strip())

    return total


def count_md_stats(file_path):
    """
    count md file stats
    """
    MD_LINES = []
    MD_INDEX = []
    with open(file_path, "r", encoding="utf-8") as fin:
        lines = fin.readlines()
        MD_LINES = [x.strip() for x in lines]

    # print title
    for x in MD_LINES:
        if x.startswith("# "):
            print(x)
            break

    print("    RAW DATA LINES", len(MD_LINES))
    MD_INDEX = list(range(len(MD_LINES)))

    CHAPTERS_2 = []  # 二级标题
    for x, y in zip(MD_LINES, MD_INDEX):
        if x.startswith("## "):
            CHAPTERS_2.append(y)

    CHAPTERS_2_ENDS = deepcopy(CHAPTERS_2)
    CHAPTERS_2_ENDS = CHAPTERS_2_ENDS + [len(MD_LINES)]
    CHAPTERS_2_ENDS.pop(0)

    OVERALL_WORDS = 0

    for begin, end in zip(CHAPTERS_2, CHAPTERS_2_ENDS):
        # print(begin, end)
        CURR = MD_LINES[begin:end]
        if len(CURR) > 0:
            print(CURR[0])
            total = 0
            for x in CURR:
                total = total + get_len_hanz(x)

            print("    words of chapter(%s)" % format_number(total))
            OVERALL_WORDS = OVERALL_WORDS + total
            print("    up to now words(%s)" % format_number(OVERALL_WORDS))

    print("")
    print("Overall Words Count: %s" % format_number(OVERALL_WORDS))

    # print(CHAPTERS_2)
    # print(len(MD_LINES[CHAPTERS_2[0]]))

    # print("get_len_hanz", get_len_hanz(MD_LINES[CHAPTERS_2[0]]))


def work():
    '''
    Workloads
    '''
    print("Process file", MD_INDEX_FILEPATH)
    count_md_stats(MD_INDEX_FILEPATH)


##########################################################################
# Testcases
##########################################################################

# run testcase: python /c/Users/Administrator/git/markdown2word-doc-template/scripts/py/count_words.py Test.testExample

class Test(unittest.TestCase):
    '''

    '''

    def setUp(self):
        pass

    def tearDown(self):
        pass

    def test_001(self):
        print("test_001")


def test():
    suite = unittest.TestSuite()
    suite.addTest(Test("test_001"))
    runner = unittest.TextTestRunner()
    runner.run(suite)


def main():
    test()


if __name__ == '__main__':
    work()
