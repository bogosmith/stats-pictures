#!/usr/bin/python

import sqlite3
import getopt
import sys
import os

def exitwith(str):
  print str
  sys.exit(2)

usage = """
Usage:   
<script_name> -d <data_directory> -n <db_name>
        """
existsdir = """
Error.Target directory does not exist.
"""
fulldir = """
Error.Target directory not empyty.
"""
baddbname = """
Error.Database name not admissible. Please use only alphanumeric characters and dots.
"""

try:
  opts = sys.argv[1:]
  optlist, ignored_args = getopt.getopt(opts, 'd:n:')
  dirname = [x[1] for x in optlist if x[0]=="-d"][0]
  dbname = [x[1] for x in optlist if x[0]=="-n"][0]
  badchars = [x for x in dbname if not (x.isalpha() or x.isdigit() or x == ".")]
  if badchars:
    baddbname
except (getopt.GetoptError, IndexError) as e:
  exitwith(usage)

if ignored_args:
  exitwith(usage)

if not os.path.exists(dirname):
  exitwith(existsdir)

if os.listdir(dirname):
  exitwith(fulldir)

"""
Crete db.
"""
conn = sqlite3.connect(dbname)
c = conn.cursor()
conn.close()
