#include "structureparser.h"
#include <ntqfile.h>
#include <ntqxml.h>
#include <ntqdom.h>

//#include <ntqwindowdefs.h>

int main( int argc, char **argv )
{
  if ( argc < 2 ) {
    fprintf( stderr, "Usage: %s <xmlfile>\n", argv[0] );
    return 1;
  }

  TQFile out_fl1("/tmp/zzzx1.svg");
  out_fl1.remove();

  StructureParser parser;
  //StructureLocator locator;
  TQXmlSimpleReader reader;
  reader.setContentHandler( &parser );
  //reader.setDocumentLocator( &parser );

  TQFile xmlFile( argv[1] );
  TQXmlInputSource source( &xmlFile );
  TQString hstr_data = source.data();
  if((!hstr_data.contains("fill:currentColor")) and (!hstr_data.contains("fill=\"currentColor\"")) and (!hstr_data.contains("stroke=\"currentColor\""))) {
    xmlFile.close();
    printf("no fix needed, exiting ..\n");
    return 0;
  }
  reader.parse( source );
  xmlFile.close();
  printf( "List1: %s\n", (const char*)parser.csch_list.join(";") );
  printf( "List2: %s\n", (const char*)parser.cscg_list.join(";") );
  printf( "List3: %s\n", (const char*)parser.csci_list.join(";") );

  TQStringList::Iterator it0 = parser.csch_list.begin();
  while( it0 != parser.csch_list.end() ) {
    TQString line0 = *it0;
    hstr_data = hstr_data.replace(hstr_data.find("fill:currentColor"), 17, "fill:" + line0);
    ++it0;
  }
  TQStringList::Iterator it1 = parser.cscg_list.begin();
  while( it1 != parser.cscg_list.end() ) {
    TQString line0 = *it1;
    hstr_data = hstr_data.replace(hstr_data.find("fill=\"currentColor\""), 19, "fill=\"" + line0 + "\"");
    ++it1;
  }
  TQStringList::Iterator it2 = parser.csci_list.begin();
  while( it2 != parser.csci_list.end() ) {
    TQString line0 = *it2;
    hstr_data = hstr_data.replace(hstr_data.find("stroke=\"currentColor\""), 21, "stroke=\"" + line0 + "\"");
    ++it2;
  }

  //write the out file
  if(out_fl1.open(IO_WriteOnly | IO_Truncate)) {
    TQTextStream out_stream(&out_fl1);
    out_stream << hstr_data;
    out_fl1.close();
  } else {
    //printf( "AAS>>\n%s\n<<AAS\n", (const char*)hstr_data );
  }

/*
see https://stackoverflow.com/questions/12637858/update-xml-file-in-qt
// Open file
TQDomDocument doc(argv[1]);
//QFile file("mydocument.xml");
if (!xmlFile.open(IO_ReadOnly)) {
    printf("Cannot open the file\n");
    return 1;
}
// Parse file
if (!doc.setContent(&xmlFile)) {
   printf("Cannot parse the content\n");
   xmlFile.close();
   return 1;
}
xmlFile.close();
TQDomElement aa_element;
*/

  return 0;
}
