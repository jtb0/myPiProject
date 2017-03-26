#!/usr/bin/env python
#coding: utf8 

###############################################################################
#                                                                             #
# python editConfFile.py </location/to/conffile.conf> <set/get> <section> <variable> <value> #
#                                                                             #
###############################################################################

import sys
import ConfigParser

DEBUG="false"
true="true"

conffile=sys.argv[1]
if (DEBUG == true) : print "conffile:" 
if (DEBUG == true) : print conffile
option=sys.argv[2]
if (DEBUG == true) : print "option:"
if (DEBUG == true) : print option
section=sys.argv[3]
if (DEBUG == true) : print "section"
if (DEBUG == true) : print section
variable=sys.argv[4]
if (DEBUG == true) : print "variable"
if (DEBUG == true) : print variable
value=sys.argv[5]
if (DEBUG == true) : print "value"
if (DEBUG == true) : print value

cp = ConfigParser.ConfigParser()
cp.read(conffile)


def optionSet(conffile, section, variable, value):  
    if (DEBUG == true) : print "set-Block:"
    if (cp.has_section(section)):
        cp.set(str(section), str(variable), str(value))
        with open(str(conffile), 'w') as configfile:
            cp.write(configfile)
    else :
        cp.add_section(section)
        cp.set(str(section), str(variable), str(value))
        with open(str(conffile), 'w') as configfile:
            cp.write(configfile)

if (option == "set"): optionSet(conffile, section, variable, value)


def optionGet(conffile, section, variable):
    if (DEBUG == true) : print "get-Block:"
    print cp.get(str(section), str(variable))
    return cp.get(str(section), str(variable))
    if (DEBUG == true) : print "end"

if (option == "get"): optionGet(conffile, section, variable)


def optionAppend(conffile, section, variable, value):
    if (DEBUG == true) : print "append-Block:"
    try:
        if (DEBUG == true) :  print "try NoOptionError"
	#try if there is already an entry at the configfile
        cp.has_option(section, variable)
	#if there is an entry read the list into the entity list1
        list1 = list(eval(cp.get(section, variable), {}, {}))
        if (DEBUG == true) : print "Hier kommt die Liste:"
        if (DEBUG == true) : print list1
	#append the value to the existing list
        list1 = list(list1) + list([value])
        if (DEBUG == true) :  print list1
    	#persist the new list in the configfile
        cp.set(str(section), str(variable), str(list1))
        with open(str(conffile), 'w') as configfile:
            cp.write(configfile)
    except ConfigParser.NoOptionError:
        if (DEBUG == true) :  print "NoOptionError raised"
	#if there is no entry for the variable at the conffile the entry will be done by the optionSet method with the value given as list object
        optionSet(conffile, section, variable, list([value]))
        if (DEBUG == true) :  print "NoOptionError raised"
        #optionAppend(conffile, section, variable, value)
    #else:   

if (option == "append"): optionAppend(conffile, section, variable, value)

if (option == "delete") :
    if (DEBUG == true) : print "delete-Block:"
    deleteList = [value]
    if (cp.has_option(section, variable)):
        list1 = eval(cp.get(section, variable), {}, {})
        if (DEBUG == true) : print "Hier kommt die Liste:"
        if (DEBUG == true) : print list1

        for index, item in enumerate(list1):
            if item in deleteList :
                list1.pop(index)
        if (DEBUG == true) :  print list1
        cp.set(str(section), str(variable), str(list1))
        with open(str(conffile), 'w') as configfile:
            cp.write(configfile)
    
