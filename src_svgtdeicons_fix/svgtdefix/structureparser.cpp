#include "structureparser.h"

#include <stdio.h>

//#include <tqstring.h>
//#include <ntqdom.h>

bool StructureParser::startDocument()
{
//    indent = "";
    csch_list.clear();
    cscg_list.clear();
    csci_list.clear();
    colorscheme_text = "#000000";
    colorscheme_hlight = "#000000";
    colorscheme_neutraltxt = "#000000";
    colorscheme_positivtxt = "#000000";
    colorscheme_negativtxt = "#000000";
    colorscheme_butttxt = "#000000";
    colorscheme_backgrnd = "#000000";
    textcss = false;
    return TRUE;
}

bool StructureParser::startElement( const TQString& arg1, const TQString& arg2,
                                    const TQString& qName,
                                    const TQXmlAttributes& qAttrbts)
{
    //printf( "EL: %s\n", (const char*)arg2 );
    //printf( "%s>%s\n", (const char*)indent, (const char*)qName );

    if((qName == "style") and (qAttrbts.value("type") == "text/css")) {
      textcss = true;
      //printf( "%s\n", (const char*)qAttrbts.value("type") ); printf( "%s\n", (const char*)qAttrbts.type("type") );
    } else {
      textcss = false;
    }

/*
ButtonBackground
ButtonFocus
ButtonHover
ViewBackground
ViewFocus
ViewHover
ViewText
*/
    if(qAttrbts.value("style").contains("fill:currentColor")) {
      if(qAttrbts.value("class") == "ColorScheme-Text") {
        csch_list << colorscheme_text;
      } else if(qAttrbts.value("class") == "ColorScheme-Highlight") {
        csch_list << colorscheme_hlight;
      } else if(qAttrbts.value("class") == "ColorScheme-NeutralText") {
        csch_list << colorscheme_neutraltxt;
      } else if(qAttrbts.value("class") == "ColorScheme-PositiveText") {
        csch_list << colorscheme_positivtxt;
      } else if(qAttrbts.value("class") == "ColorScheme-NegativeText") {
        csch_list << colorscheme_negativtxt;
      } else if(qAttrbts.value("class") == "ColorScheme-ButtonText") {
        csch_list << colorscheme_butttxt;
      } else if(qAttrbts.value("class") == "ColorScheme-Background") {
        csch_list << colorscheme_backgrnd;
      } else {
        csch_list << "#888888";
      }
    }
    if(qAttrbts.value("fill") == "currentColor") {
      if(qAttrbts.value("class") == "ColorScheme-Text") {
        cscg_list << colorscheme_text;
      } else if(qAttrbts.value("class") == "ColorScheme-Highlight") {
        cscg_list << colorscheme_hlight;
      } else if(qAttrbts.value("class") == "ColorScheme-NeutralText") {
        cscg_list << colorscheme_neutraltxt;
      } else if(qAttrbts.value("class") == "ColorScheme-PositiveText") {
        cscg_list << colorscheme_positivtxt;
      } else if(qAttrbts.value("class") == "ColorScheme-NegativeText") {
        cscg_list << colorscheme_negativtxt;
      } else if(qAttrbts.value("class") == "ColorScheme-ButtonText") {
        cscg_list << colorscheme_butttxt;
      } else if(qAttrbts.value("class") == "ColorScheme-Background") {
        cscg_list << colorscheme_backgrnd;
      } else {
        cscg_list << "#888888";
      }
    }
    if(qAttrbts.value("stroke") == "currentColor") {
      if(qAttrbts.value("class") == "ColorScheme-Text") {
        csci_list << colorscheme_text;
      } else if(qAttrbts.value("class") == "ColorScheme-Highlight") {
        csci_list << colorscheme_hlight;
      } else if(qAttrbts.value("class") == "ColorScheme-NeutralText") {
        csci_list << colorscheme_neutraltxt;
      } else if(qAttrbts.value("class") == "ColorScheme-PositiveText") {
        csci_list << colorscheme_positivtxt;
      } else if(qAttrbts.value("class") == "ColorScheme-NegativeText") {
        csci_list << colorscheme_negativtxt;
      } else if(qAttrbts.value("class") == "ColorScheme-ButtonText") {
        csci_list << colorscheme_butttxt;
      } else if(qAttrbts.value("class") == "ColorScheme-Background") {
        csci_list << colorscheme_backgrnd;
      } else {
        csci_list << "#888888";
      }
    }

//    indent += "  ";
    return TRUE;
}

bool StructureParser::endElement( const TQString&, const TQString&, const TQString& qName )
{
//    indent.remove( (uint)0, 2 );
    //printf( "%s<%s\n", (const char*)indent, (const char*)qName );
    return TRUE;
}

bool StructureParser::characters( const TQString& value1 )
{
    if((textcss) and (value1)) {
      TQString hstr1 = value1;
      //hstr1 = hstr1.stripWhiteSpace();
      hstr1 = hstr1.stripWhiteSpace().remove(" ").remove('"').remove("'").remove("}").remove('\n');
      if(! hstr1.isEmpty()) {
        //printf( "%s\n", (const char*)hstr1 );
        colorscheme_text       = hstr1.section(".ColorScheme-Text", 1, 1);
        colorscheme_hlight     = hstr1.section(".ColorScheme-Highlight", 1, 1);
        colorscheme_neutraltxt = hstr1.section(".ColorScheme-NeutralText", 1, 1);
        colorscheme_positivtxt = hstr1.section(".ColorScheme-PositiveText", 1, 1);
        colorscheme_negativtxt = hstr1.section(".ColorScheme-NegativeText", 1, 1);
        colorscheme_butttxt    = hstr1.section(".ColorScheme-ButtonText", 1, 1);
        colorscheme_backgrnd   = hstr1.section(".ColorScheme-Background", 1, 1);
        colorscheme_text       = colorscheme_text.section      ("color:", 1, 1).section(";", 0, 0);
        colorscheme_hlight     = colorscheme_hlight.section    ("color:", 1, 1).section(";", 0, 0);
        colorscheme_neutraltxt = colorscheme_neutraltxt.section("color:", 1, 1).section(";", 0, 0);
        colorscheme_positivtxt = colorscheme_positivtxt.section("color:", 1, 1).section(";", 0, 0);
        colorscheme_negativtxt = colorscheme_negativtxt.section("color:", 1, 1).section(";", 0, 0);
        colorscheme_butttxt    = colorscheme_butttxt.section   ("color:", 1, 1).section(";", 0, 0);
        colorscheme_backgrnd   = colorscheme_backgrnd.section  ("color:", 1, 1).section(";", 0, 0);
        printf( "ColorScheme-Text: %s\n", (const char*)colorscheme_text );
        printf( "ColorScheme-Highlight: %s\n", (const char*)colorscheme_hlight );
        printf( "ColorScheme-NeutralText: %s\n", (const char*)colorscheme_neutraltxt );
        printf( "ColorScheme-PositiveText: %s\n", (const char*)colorscheme_positivtxt );
        printf( "ColorScheme-NegativeText: %s\n", (const char*)colorscheme_negativtxt );
        printf( "ColorScheme-ButtonText: %s\n", (const char*)colorscheme_butttxt );
        printf( "ColorScheme-Background: %s\n", (const char*)colorscheme_backgrnd );
      }
    }
    return TRUE;
}
