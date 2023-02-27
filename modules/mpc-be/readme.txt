1、将 MFC EXE ，修改为 MFC DLL；
2、修改 CMPlayerCApp::InitInstance()；
3、添加 Dll 导出函数；

注：
  还需要修改一些东东，因为 EXE 和 DLL 差别，修改量很小。
  1、模块句柄；一般 EXE 中，模块句柄是自己、本身，所以一般参数为空。DLL 中，就不是了。需修改；
  2、窗体位置；一些程序，都会在程序创建时，设置窗体位置。这个需要删除掉；
  3、MPC-BE 源代码中，Detour 用完没有释放，需释放掉；
  4、使用的 MPC-BE 版本 5500；
  5、MPC-BE 源码地址：https://svn.code.sf.net/p/mpcbe/code/trunk



MFC 封装

    MFC EXE

      _tWinMain    ---> AfxWinMain  ---> pThread->InitInstance
                                                 │
                                                 ↓
      appmodul.cpp ---> winmain.cpp ---> 用户代码(CxxxApp::InitInstance；CxxxApp 继承于 CWinApp)
     │-------> 系统封装的代码 <------ │
     │   库：  nafxcw.lib (ANSI)      │
     │   库：  uafxcw.lib (UNICODE)   │




    MFC DLL (静态标准MFC DLL)
    
      DllMain  ---> InternalDllMain ---> InitInstance
                                             │
                                             ↓
       dllmodul.cpp -------------------> 用户代码(InitInstance)
     │-------> 系统封装的代码 <------ │
     │   库：  nafxcw.lib (ANSI)      │
     │   库：  uafxcw.lib (UNICODE)   │



   ┌─────┬─────────────┬────────────────┐
   │          │          SDK		       │		          MFC            │
   ├─────┼──────┬──────┼───────┬────────┤
   │          │    EXE     │   DLL      │     EXE      │   DLL          │
   ├─────┼──────┼──────┼───────┼────────┤
   │ DEBUG    │LIBCMTD.LIB │MSVCRTD.LIB │              │                │
   ├─────┼──────┼──────┼───────┼────────┤
   │ RELEASE  │LIBCMT.LIB  │MSVCRT.LIB  │              │                │
   └─────┴──────┴──────┴───────┴────────┘

C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\VC\Tools\MSVC\14.27.29110\atlmfc\src\mfc
