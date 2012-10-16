#! /usr/bin/env python

from parser import file_parser as FP
import pdb

DO_DEBUG = False

if DO_DEBUG:
    pdb.set_trace()

file_parser = FP.FileParser()

try:
    file_parser.open()
  
    mismatch_count, mismatch_list = file_parser.compare(True) 
    if mismatch_count < 0:
        print "The comparison fails for some reasons......"
    else:
        print "There are totally {0} mismatch(es) found !!!".format(mismatch_count)
        if mismatch_count > 0:
            print "The country list with mismatch(es): {0}".format(mismatch_list)
except (EnvironmentError, ValueError, KeyError) as err:
    print("Exception: {0}".format(err))
finally:
    file_parser.close()
