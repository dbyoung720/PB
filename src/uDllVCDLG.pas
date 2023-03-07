unit uDllVCDLG;
{
  Func : VC DLG DLL Form Create / Free Manager
  Auth : dbyoung@sina.com
  Time : 2023-02-10
}

interface

uses Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Forms, Vcl.ComCtrls, HookUtils, uBaseForm;

{ 运行 VC DLG DLL Form 窗体 }
procedure ShowVCDLGDllForm(const strVCDllFileName: String; tsDll: TTabSheet);

{ 检查上一次创建的 VC DLG DLL Form 是否关闭 }
procedure CheckLastVCDLGDllClose(const bExit: Boolean = False);

implementation

var
  FTabDllForm            : TTabSheet;
  FOld_CreateWindowExW   : function(dwExStyle: DWORD; lpClassName: LPCWSTR; lpWindowName: LPCWSTR; dwStyle: DWORD; X, Y, nWidth, nHeight: Integer; hWndParent: hWnd; hMenu: hMenu; hins: HINST; lpp: Pointer): hWnd; stdcall;
  FstrVCDLGDllClassName  : String = '';
  FstrVCDLGDllWindowName : String = '';
  FstrBakVCDLGDllFileName: String = '';
  FstrNewVCDLGDllFileName: String;
  FhVCDLGDllModule       : HMODULE;
  FhVCDLGDLLForm         : THandle;
  FLangStyle             : TLangStyle;
  FbExit                 : Boolean = False;

procedure DLog(const strLog: String);
begin
  OutputDebugString(PChar(Format('%s  %s', [FormatDateTime('yyyy-MM-dd hh:mm:ss', Now), strLog])));
end;

{ 创建 VC DLL 窗体 }
procedure CreateVCDllForm;
begin
  FTabDllForm.PageControl.ActivePage := FTabDllForm;                                                                             //
  Winapi.Windows.SetParent(FhVCDLGDLLForm, FTabDllForm.Handle);                                                                  // 设置父窗体为 TabSheet
  RemoveMenu(GetSystemMenu(FhVCDLGDLLForm, False), 0, MF_BYPOSITION);                                                            // 删除移动菜单
  RemoveMenu(GetSystemMenu(FhVCDLGDLLForm, False), 0, MF_BYPOSITION);                                                            // 删除移动菜单
  RemoveMenu(GetSystemMenu(FhVCDLGDLLForm, False), 0, MF_BYPOSITION);                                                            // 删除移动菜单
  RemoveMenu(GetSystemMenu(FhVCDLGDLLForm, False), 0, MF_BYPOSITION);                                                            // 删除移动菜单
  RemoveMenu(GetSystemMenu(FhVCDLGDLLForm, False), 0, MF_BYPOSITION);                                                            // 删除移动菜单
  RemoveMenu(GetSystemMenu(FhVCDLGDLLForm, False), 0, MF_BYPOSITION);                                                            // 删除移动菜单
  RemoveCaption(FhVCDLGDLLForm);                                                                                                 // 去除标题栏
  SetWindowPos(FhVCDLGDLLForm, FTabDllForm.Handle, 0, 0, FTabDllForm.Width, FTabDllForm.Height, SWP_NOZORDER OR SWP_NOACTIVATE); // 最大化 DLL 子窗体
  PostMessage(Application.MainForm.Handle, WM_NCACTIVATE, 1, 0);                                                                 // 激活主窗体
  UnHook(@FOld_CreateWindowExW);                                                                                                 // UNHOOK
  FOld_CreateWindowExW := nil;                                                                                                   // UNHOOK
end;

function HookCreateWindowExW(dwExStyle: DWORD; lpClassName: LPCWSTR; lpWindowName: LPCWSTR; dwStyle: DWORD; X, Y, nWidth, nHeight: Integer; hWndParent: hWnd; hMenu: hMenu; hins: HINST; lpp: Pointer): hWnd; stdcall;
begin
  { 是指定的 VC 窗体 }
  if (lpClassName <> nil) and (lpWindowName <> nil) and (SameText(lpClassName, FstrVCDLGDllClassName)) and (SameText(lpWindowName, FstrVCDLGDllWindowName)) then
  begin
    { 创建 VC DLG DLL Form 窗体 }
    Result         := FOld_CreateWindowExW($00010101, lpClassName, lpWindowName, $96C80000, 0, 0, 0, 0, hWndParent, hMenu, hins, lpp); //
    FhVCDLGDLLForm := Result;
    CreateVCDllForm;
  end
  else
  begin
    Result := FOld_CreateWindowExW(dwExStyle, lpClassName, lpWindowName, dwStyle, X, Y, nWidth, nHeight, hWndParent, hMenu, hins, lpp);
  end;
end;

procedure FindVCDLGDLLFormEnd(hWnd: hWnd; uMsg, idEvent: UINT; dwTime: DWORD); stdcall;
begin
  if FhVCDLGDllModule = 0 then
  begin
    KillTimer(Application.MainForm.Handle, c_intVCDLGDllFormEndTimerID);
    ShowVCDLGDllForm(FstrNewVCDLGDllFileName, FTabDllForm);
  end;
end;

{ 运行 VC DLG DLL Form 窗体 }
procedure ShowVCDLGDllForm(const strVCDllFileName: String; tsDll: TTabSheet);
var
  hDll                             : HMODULE;
  ShowVCDllForm                    : Tdb_ShowDllForm_Plugins_VCForm;
  strParamModuleName, strModuleName: PAnsiChar;
  strClassName, strWindowName      : PAnsiChar;
begin
  { 等待先前的 VC DLG DLL Form 模态窗体销毁完成，才能进行新的 DLL 创建 }
  if FhVCDLGDllModule <> 0 then
  begin
    FstrNewVCDLGDllFileName := strVCDllFileName;
    FTabDllForm             := tsDll;
    SetTimer(Application.MainForm.Handle, c_intVCDLGDllFormEndTimerID, 200, @FindVCDLGDLLFormEnd);
    Exit;
  end;

  if CompareText(FstrBakVCDLGDllFileName, strVCDllFileName) = 0 then
    Exit;

  FTabDllForm             := tsDll;
  FstrBakVCDLGDllFileName := strVCDllFileName;
  FbExit                  := False;

  { 只获取参数，不调用显示窗体。下 HOOK，HOOK 指定窗体 }
  hDll := LoadLibrary(PChar(strVCDllFileName));
  try
    ShowVCDllForm := GetProcAddress(hDll, c_strDllExportFuncName);
    ShowVCDllForm(FLangStyle, strParamModuleName, strModuleName, strClassName, strWindowName, False);
    FstrVCDLGDllClassName  := String(strClassName);
    FstrVCDLGDllWindowName := String(strWindowName);
    HookProcInModule(user32, 'CreateWindowExW', @HookCreateWindowExW, @FOld_CreateWindowExW);
  finally
    FreeLibrary(hDll);
  end;

  { 加载 VC DLG Dll Form 模态窗体；窗体关闭即释放 }
  FhVCDLGDllModule := LoadLibrary(PChar(strVCDllFileName));
  ShowVCDllForm    := GetProcAddress(FhVCDLGDllModule, c_strDllExportFuncName);
  ShowVCDllForm(FLangStyle, strParamModuleName, strModuleName, strClassName, strWindowName, True);

  { 全局变量复位 }
  FreeLibrary(FhVCDLGDllModule);
  FhVCDLGDllModule        := 0;
  FhVCDLGDLLForm          := 0;
  FstrVCDLGDllClassName   := '';
  FstrVCDLGDllWindowName  := '';
  FstrBakVCDLGDllFileName := '';
  RestoreDefultTabSheet(tsDll.PageControl);
  if FbExit then
  begin
    Application.MainForm.Close;
  end;
end;

{ 检查上一次创建的 VC DLG DLL Form 是否关闭 }
procedure CheckLastVCDLGDllClose(const bExit: Boolean = False);
begin
  if FhVCDLGDLLForm = 0 then
    Exit;

  FbExit := bExit;

  { 发送关闭窗体命令 }
  PostMessage(FhVCDLGDLLForm, WM_SYSCOMMAND, SC_CLOSE, 0);
end;

end.
