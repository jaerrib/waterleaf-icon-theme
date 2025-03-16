TEMPLATE	= app
TARGET          = svgtdefix

CONFIG		+= qt console warn_on release

REQUIRES	= xml large-config

HEADERS		= structureparser.h

SOURCES		= svgtdefix.cpp structureparser.cpp
