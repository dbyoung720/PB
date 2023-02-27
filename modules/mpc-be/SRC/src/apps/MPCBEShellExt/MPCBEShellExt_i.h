

/* this ALWAYS GENERATED file contains the definitions for the interfaces */


 /* File created by MIDL compiler version 8.01.0622 */
/* at Tue Jan 19 11:14:07 2038
 */
/* Compiler settings for MPCBEShellExt.idl:
    Oicf, W1, Zp8, env=Win64 (32b run), target_arch=AMD64 8.01.0622 
    protocol : all , ms_ext, c_ext, robust
    error checks: allocation ref bounds_check enum stub_data 
    VC __declspec() decoration level: 
         __declspec(uuid()), __declspec(selectany), __declspec(novtable)
         DECLSPEC_UUID(), MIDL_INTERFACE()
*/
/* @@MIDL_FILE_HEADING(  ) */



/* verify that the <rpcndr.h> version is high enough to compile this file*/
#ifndef __REQUIRED_RPCNDR_H_VERSION__
#define __REQUIRED_RPCNDR_H_VERSION__ 500
#endif

#include "rpc.h"
#include "rpcndr.h"

#ifndef __RPCNDR_H_VERSION__
#error this stub requires an updated version of <rpcndr.h>
#endif /* __RPCNDR_H_VERSION__ */

#ifndef COM_NO_WINDOWS_H
#include "windows.h"
#include "ole2.h"
#endif /*COM_NO_WINDOWS_H*/

#ifndef __MPCBEShellExt_i_h__
#define __MPCBEShellExt_i_h__

#if defined(_MSC_VER) && (_MSC_VER >= 1020)
#pragma once
#endif

/* Forward Declarations */ 

#ifndef __IMPCBEContextMenu_FWD_DEFINED__
#define __IMPCBEContextMenu_FWD_DEFINED__
typedef interface IMPCBEContextMenu IMPCBEContextMenu;

#endif 	/* __IMPCBEContextMenu_FWD_DEFINED__ */


#ifndef __MPCBEContextMenu_FWD_DEFINED__
#define __MPCBEContextMenu_FWD_DEFINED__

#ifdef __cplusplus
typedef class MPCBEContextMenu MPCBEContextMenu;
#else
typedef struct MPCBEContextMenu MPCBEContextMenu;
#endif /* __cplusplus */

#endif 	/* __MPCBEContextMenu_FWD_DEFINED__ */


/* header files for imported files */
#include "oaidl.h"
#include "ocidl.h"

#ifdef __cplusplus
extern "C"{
#endif 


#ifndef __IMPCBEContextMenu_INTERFACE_DEFINED__
#define __IMPCBEContextMenu_INTERFACE_DEFINED__

/* interface IMPCBEContextMenu */
/* [unique][helpstring][uuid][object] */ 


EXTERN_C const IID IID_IMPCBEContextMenu;

#if defined(__cplusplus) && !defined(CINTERFACE)
    
    MIDL_INTERFACE("6F28F887-69C8-4ADD-9E5F-FDDBFC2ABBED")
    IMPCBEContextMenu : public IUnknown
    {
    public:
    };
    
    
#else 	/* C style interface */

    typedef struct IMPCBEContextMenuVtbl
    {
        BEGIN_INTERFACE
        
        HRESULT ( STDMETHODCALLTYPE *QueryInterface )( 
            IMPCBEContextMenu * This,
            /* [in] */ REFIID riid,
            /* [annotation][iid_is][out] */ 
            _COM_Outptr_  void **ppvObject);
        
        ULONG ( STDMETHODCALLTYPE *AddRef )( 
            IMPCBEContextMenu * This);
        
        ULONG ( STDMETHODCALLTYPE *Release )( 
            IMPCBEContextMenu * This);
        
        END_INTERFACE
    } IMPCBEContextMenuVtbl;

    interface IMPCBEContextMenu
    {
        CONST_VTBL struct IMPCBEContextMenuVtbl *lpVtbl;
    };

    

#ifdef COBJMACROS


#define IMPCBEContextMenu_QueryInterface(This,riid,ppvObject)	\
    ( (This)->lpVtbl -> QueryInterface(This,riid,ppvObject) ) 

#define IMPCBEContextMenu_AddRef(This)	\
    ( (This)->lpVtbl -> AddRef(This) ) 

#define IMPCBEContextMenu_Release(This)	\
    ( (This)->lpVtbl -> Release(This) ) 


#endif /* COBJMACROS */


#endif 	/* C style interface */




#endif 	/* __IMPCBEContextMenu_INTERFACE_DEFINED__ */



#ifndef __MPCBEShellExtLib_LIBRARY_DEFINED__
#define __MPCBEShellExtLib_LIBRARY_DEFINED__

/* library MPCBEShellExtLib */
/* [helpstring][version][uuid] */ 


EXTERN_C const IID LIBID_MPCBEShellExtLib;

EXTERN_C const CLSID CLSID_MPCBEContextMenu;

#ifdef __cplusplus

class DECLSPEC_UUID("A2CF4243-6525-4764-B3F5-2FCDE2F47989")
MPCBEContextMenu;
#endif
#endif /* __MPCBEShellExtLib_LIBRARY_DEFINED__ */

/* Additional Prototypes for ALL interfaces */

/* end of Additional Prototypes */

#ifdef __cplusplus
}
#endif

#endif


