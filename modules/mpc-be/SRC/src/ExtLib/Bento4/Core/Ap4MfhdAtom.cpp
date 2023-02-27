/*****************************************************************
|
|    AP4 - mfhd Atoms
|
|    Copyright 2014 Aleksoid1978
|
 ****************************************************************/

/*----------------------------------------------------------------------
|       includes
+---------------------------------------------------------------------*/

#include "Ap4.h"
#include "Ap4MfhdAtom.h"

/*----------------------------------------------------------------------
|       AP4_MfhdAtom::AP4_MfhdAtom
+---------------------------------------------------------------------*/

AP4_MfhdAtom::AP4_MfhdAtom(AP4_Size         size,
                           AP4_ByteStream&  stream)
    : AP4_Atom(AP4_ATOM_TYPE_MFHD, size, true, stream)
    , m_SequenceNumber(0)
{
    stream.ReadUI32(m_SequenceNumber);
}
