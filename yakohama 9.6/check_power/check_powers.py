#! /usr/bin/env python

#http://www.python-excel.org/


from parser import file_parser as FP

"""
book = xlrd.open_workbook('Country matrix 2012 07 17.xls')
print book.nsheets
print book.sheet_names()

sh = book.sheet_by_index(0)
print sh.name, sh.nrows, sh.ncols

for rownum in range(sh.nrows):
    print sh.row_values(rownum)

print sh.row_values(10)

value_A1 = sh.cell(3, 1).value
print value_A1

value_A1 = int(sh.cell(10, 13).value)
print value_A1
"""

file_parser = FP.FileParser()

try:
    file_parser.open()
  
    file_parser.compare()
except (EnvironmentError, ValueError, KeyError) as err:
    print("Exception: {0}".format(err))
finally:
    file_parser.close()



