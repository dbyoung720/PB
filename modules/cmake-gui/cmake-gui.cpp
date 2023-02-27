#include <windows.h>

HINSTANCE hinst = NULL;

BOOL APIENTRY DllMain(HMODULE hModule, DWORD ul_reason_for_call, LPVOID lpReserved)
{
    switch (ul_reason_for_call)
    {
      case DLL_PROCESS_ATTACH:
        hinst = (HINSTANCE)hModule;
      case DLL_THREAD_ATTACH:
      case DLL_THREAD_DETACH:
      case DLL_PROCESS_DETACH:
          break;
    }
    return TRUE;
}

enum TLangStyle {lsDelphiDll, lsVCDLGDll, lsVCMFCDll, lsQTDll, lsEXE};

extern int WINAPI WinMain(HINSTANCE hInstance,HINSTANCE hPrevInst,LPSTR lpCmdLine,int nCmdShow);

extern "C" __declspec(dllexport) void db_ShowDllForm_Plugins(TLangStyle* lsFileType, char** strParentName, char** strSubModuleName, char** strClassName, char** strWindowName, const bool show = false)
{
    * lsFileType       = lsQTDll;                 // TLangStyle
    * strParentName    = "程序员工具";            // 父模块名称
    * strSubModuleName = "CMake-GUI(DLL)";        // 子模块名称
    * strClassName     = "Qt5152QWindowIcon";     // 窗体类名
    * strWindowName    = "CMakeSetup";            // 窗体名
    
    if (show) 
    {
      WinMain(hinst, 0, (LPSTR)"", (int)show);
    }
}

