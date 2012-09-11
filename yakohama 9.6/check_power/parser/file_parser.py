#! /usr/bin/env python

import xlrd

XLS_filename = "Country matrix 2012 07 17.xls"
Header_filename = "regdmn_chan.h"

class FileParser:    
# privte:
    def __init__(self):
        self.is_open = False
        self.XLS_book = None
        self.XLS_sheet = None
        self.Header_fd = None

    def _openXLS(self):
        self.XLS_book = xlrd.open_workbook(XLS_filename)
        self.XLS_sheet = self.XLS_book.sheet_by_index(0)

    def _openHeader(self):
        self.Header_fd = open(Header_filename)

    def _closeXLS(self):
        if self.XLS_book is not None:
            self.XLS_book.release_resources()
            self.XLS_book = None

    def _closeHeader(self):
        if self.Header_fd is not None:
            self.Header_fd.close()
            self.Header_fd = None

# public:
    def open(self):
        self._openXLS()
        self._openHeader()
        self.is_open = True

    def close(self):
        self.is_open = False
        self._closeHeader
        self._closeXLS()

    def compare(self):
        if self.is_open is not True:
            return False
        
# Try to find the first line of the data        
        header_data_begin = False
        lino_begin = 0        
        for lino, line in enumerate(self.Header_fd, start = 1):
            line = line.rstrip()
            if not line:
                continue
            
            if header_data_begin is not True:
                if line.find("regdmn_pwr_table[NUM_REGDMNS]") is not -1:
                    header_data_begin = True
                    lino_begin = lino
                    break;
        lino_begin = lino_begin + 1
# Useful data are found, start to parse them            
        for lino, line in enumerate(self.Header_fd, start = lino_begin):
            print("Line : {0}, {1}".format(lino, line))        

    


 
