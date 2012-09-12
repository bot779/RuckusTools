#! /usr/bin/env python

import xlrd

XLS_filename = "Country matrix 2012 07 17.xls"
XLS_start_rowx = 10
XLS_start_colx = 34
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
            if header_data_begin is True:
                break
            line = line.rstrip()
            if not line:
                continue
            
            if header_data_begin is not True:
                if line.find("regdmn_pwr_table[NUM_REGDMNS]") is not -1:
                    header_data_begin = True
                    lino_begin = lino

        lino_begin = lino_begin + 2
# Useful data are found, start to parse them
        country_name = ""
        country_name_XLS = ""
        power_data = tuple()    
        lino_XLS = 0
        for lino, line in enumerate(self.Header_fd, start = 1):
            line = line.rstrip()
            if line.find("};") is not -1:
                break;
            if lino % 2 != 0:
# Parse the country name
                country_name = line.lstrip("{ \"").rstrip("\",")
            else:
# Parse the data form a specified country
                line = line.lstrip("{{{").rstrip("},}}},")
                line = line.replace("},{", ",")
                line = "(" + line + ")"
                power_data = tuple(int(ele) for ele in line[1:-1].split(","))
                
                country_name_XLS = self.XLS_sheet.cell(XLS_start_rowx + lino_XLS, 1).value
# The country name in this row is empty, try to find the next one...
                if country_name_XLS == "":
                    while country_name_XLS == "":
                        lino_XLS = lino_XLS + 1
                        country_name_XLS = self.XLS_sheet.cell(XLS_start_rowx + lino_XLS, 1).value

#                if country_name != country_name_XLS:
#                    print "Different {0}, {1}".format(country_name, country_name_XLS)
# Compare each data in the two files
                for i in range(36):
                    need_print_title = True
                    power_data_ele_XLS = int(self.XLS_sheet.cell(XLS_start_rowx + lino_XLS, XLS_start_rowx + i).value)
                    if power_data[i] != power_data_ele_XLS:
# Consider the special case
                        if power_data[i] == -128 && power_data_ele_XLS == None:
                            continue                
                        if need_print_title is True:
                            print "{0}: \n".format(country_name)
                            need_print_title = False                            
                        
                    
                lino_XLS = lino_XLS + 1
                
                print country_name
                print country_name_XLS
#                print power_data
                                
#            print("Line : {0}, {1}".format(lino, line))    
