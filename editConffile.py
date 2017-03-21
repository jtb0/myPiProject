#!/usr/bin/env python
#coding: utf8 

###############################################################################
#                                                                             #
# python editConfFile.py </location/to/conffile.conf> <set/get> <section> <variable> <value> #
#                                                                             #
###############################################################################

import sys
import ConfigParser

cp = ConfigParser.ConfigParser()
cp.read(sys.argv[1])

if (sys.argv[2] == "set") : 
    if (cp.has_section(sys.argv[3])):
        cp.set(str(sys.argv[3]), str(sys.argv[4]), str(sys.argv[5]))
        with open(str(sys.argv[1]), 'w') as configfile:
            cp.write(configfile)
    else :
        cp.add_section(sys.argv[3])
        cp.set(str(sys.argv[3]), str(sys.argv[4]), str(sys.argv[5]))
        with open(str(sys.argv[1]), 'w') as configfile:
            cp.write(configfile)

if (sys.argv[2] == "get") : cp.get(str(sys.argv[3]), str(sys.argv[4]))

