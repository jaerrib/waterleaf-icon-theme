#ifndef STRUCTUREPARSER_H
#define STRUCTUREPARSER_H

#include <ntqxml.h>

class TQString;

class StructureParser : public TQXmlDefaultHandler
{
public:
    bool startDocument();
    bool startElement( const TQString&, const TQString&, const TQString& , 
                       const TQXmlAttributes& );
    bool endElement( const TQString&, const TQString&, const TQString& );

    bool characters ( const TQString & );

    TQString colorscheme_text;
    TQString colorscheme_hlight;
    TQString colorscheme_neutraltxt;
    TQString colorscheme_positivtxt;
    TQString colorscheme_negativtxt;
    TQString colorscheme_butttxt;
    TQString colorscheme_backgrnd;

    TQStringList csch_list;
    TQStringList cscg_list;
    TQStringList csci_list;

private:
    bool textcss;
//    TQString indent;
};


/*
class StructureLocator : public TQXmlLocator
{
public:
    //int lineNumber();

private:
};
*/

#endif
