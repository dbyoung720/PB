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
    * lsFileType       = lsVCDLGDll;      // TLangStyle
    * strParentName    = "文本编辑";      // 父模块名称
    * strSubModuleName = "Notepad2(DLL)"; // 子模块名称
    * strClassName     = "Notepad2U";     // 窗体类名
    * strWindowName    = "Notepad2";      // 窗体名
    
    if (show) 
    {
      WinMain(hinst, 0, (LPSTR)"", (int)show);
    }
}

