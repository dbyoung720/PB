PB(PBox)
=============

# PB(PBox) is a modular development platform based on DLL Window

- [��������](readmeCN.md)

## I. Development purpose
    Based on the principle of minimizing or not modifying the original project source code(Delphi��VC��QT);
    Support Delphi DLL Form��VC DLL Window(Dialog/MFC)��QT DLL Window; 

## II. Development platform
    Delphi11.3��WIN10X64;
    WIN10X64 test pass;Support X86��X64;
    Email��dbyoung@sina.com;
    QQgrp��101611228;

## III.Usage 
### Delphi��
* Delphi original exe project, modified to DLL project. Output export function, the original code without any modification;
* Put the compiled DLL file in the plugins directory;
* Example: modules\CurlUI;
* Example: modules\sPath;
* Example: modules\pm;
* Delphi function declaration:  
```
 procedure db_ShowDllForm_Plugins(var frm: TFormClass; var strParentModuleName, strSubModuleName: PAnsiChar); stdcall;
```
### VC2022
* Convert VC window exe to DLL for calling by other languages: [https://blog.csdn.net/dbyoung/article/details/103987103]
* VC original EXE(base on Dialog) project��without any modifitication��new a dll.cpp file��output export function;
* VC original EXE(base on    MFC) project��need a little modify code;
* Put the compiled DLL file in the plugins directory;
* Example(base on Dialog)��modules\7-zip
* Example(base on Dialog)��modules\Notepad2;
* Example(base on    MFC)��modules\mpc-be;
* VC2022 function declaration:  
```
enum TLangStyle {lsDelphiDll, lsVCDLGDll, lsVCMFCDll, lsQTDll, lsEXE};
extern "C" __declspec(dllexport) void db_ShowDllForm_Plugins(TLangStyle* lsFileType, char** strParentName, char** strSubModuleName, char** strClassName, char** strWindowName, const bool show = false)
```

### QT
* QT original EXE��without any modifitication��Compile to exe;
* New a dll.cpp file��output export function; together compile to dll;
* Put the compiled DLL file in the plugins directory;
* Same as VC Dialog DLL;
* Example��modules\cmake-gui;
* Example��modules\qBittorrent��
* function declaration:
```
enum TLangStyle {lsDelphiDll, lsVCDLGDll, lsVCMFCDll, lsQTDll, lsEXE};
extern "C" __declspec(dllexport) void db_ShowDllForm_Plugins(TLangStyle* lsFileType, char** strParentName, char** strSubModuleName, char** strClassName, char** strWindowName, const bool show = false)
```


## IV: Description of DLL output function parameters 
* Delphi ��
```
 procedure db_ShowDllForm_Plugins(var frm: TFormClass; var strParentModuleName, strSubModuleName: PAnsiChar); stdcall;

 frm                 ��DLL main window class name in Delphi;
 strParentModuleName ��Parent module name;  
 strSubModuleName    ��Sub module name;  
```
* VC2022/QT ��
```
extern "C" __declspec(dllexport) void db_ShowDllForm_Plugins(TLangStyle* lsFileType, char** strParentName, char** strSubModuleName, char** strClassName, char** strWindowName, const bool show = false)

 lsFileType        ��Base on Dialog DLL��or base MFC DLL or QT DLL;
 strParentName     ��Parent module name;  
 strSubModuleName  ��Sub module name; 
 strClassName      ��DLL Main window class name;
 strWindowName     ��DLL Main window title name;
 show              ��show/hide DLL main window;
```

## V. Features 
    The UI supports menu display, button (dialog box) display and list view display;  
    Supports the display of an EXE window program in our window; 
    Support the EXE program of dynamic change of window class name;support multiple document windows;
    Support file drag and drop to exe and DLL window; 
    Support x86 EXE call x64 EXE, x64 EXE call x86 EXE;
    
## VI. Known bugs:  
    1. File drag and drop can only be dragged and dropped to the main window, not directly to the sub module DLL window; This is a problem caused by permissions (resource manager is normal permissions and pbox is administrator permissions);

## VII. Next work:  
    Add database support (because I am not familiar with the database, the development is slow, and it is developed in my spare time)  
