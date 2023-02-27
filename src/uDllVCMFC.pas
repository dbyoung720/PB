unit uDllVCMFC;
{
  Func : VC MFC DLL Form Create / Free Manager
  Auth : dbyoung@sina.com
  Time : 2023-02-10
}

interface

uses Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Forms, Vcl.ComCtrls, HookUtils, uBaseForm;

{ 运行 VC MFC DLL 窗体 }
procedure ShowVCMFCDllForm(const strFileName: String; tsDll: TTabSheet);

{ 检查上一次创建的 VC MFC DLL Form 是否关闭 }
procedure CheckLastVCMFCDllClose;

implementation

var
  FTabDllForm            : TTabSheet;
  FOld_CreateWindowExW   : function(dwExStyle: DWORD; lpClassName: LPCWSTR; lpWindowName: LPCWSTR; dwStyle: DWORD; X, Y, nWidth, nHeight: Integer; hWndParent: hWnd; hMenu: hMenu; hins: HINST; lpp: Pointer): hWnd; stdcall;
  FstrVCMFCDllClassName  : String = '';
  FstrVCMFCDllWindowName : String = '';
  FstrBakVCMFCDllFileName: String = '';
  FstrNewVCDLGDllFileName: String = '';
  FhVCMFCDllModule       : HMODULE;
  FhVCMFCDLLForm         : THandle;
  FLangStyle             : TLangStyle;

procedure DLog(const strLog: String);
begin
  OutputDebugString(PChar(Format('%s  %s', [FormatDateTime('yyyy-MM-dd hh:mm:ss', Now), strLog])));
end;

{ 创建 VC DLL 窗体 }
procedure CreateVCDllForm;
begin
  FTabDllForm.PageControl.ActivePage := FTabDllForm;                                                                             //
  Winapi.Windows.SetParent(FhVCMFCDLLForm, FTabDllForm.Handle);                                                                  // 设置父窗体为 TabSheet
  RemoveMenu(GetSystemMenu(FhVCMFCDLLForm, False), 0, MF_BYPOSITION);                                                            // 删除移动菜单
  RemoveMenu(GetSystemMenu(FhVCMFCDLLForm, False), 0, MF_BYPOSITION);                                                            // 删除移动菜单
  RemoveMenu(GetSystemMenu(FhVCMFCDLLForm, False), 0, MF_BYPOSITION);                                                            // 删除移动菜单
  RemoveMenu(GetSystemMenu(FhVCMFCDLLForm, False), 0, MF_BYPOSITION);                                                            // 删除移动菜单
  RemoveMenu(GetSystemMenu(FhVCMFCDLLForm, False), 0, MF_BYPOSITION);                                                            // 删除移动菜单
  RemoveMenu(GetSystemMenu(FhVCMFCDLLForm, False), 0, MF_BYPOSITION);                                                            // 删除移动菜单
  RemoveCaption(FhVCMFCDLLForm);                                                                                                 // 去除标题栏
  SetWindowPos(FhVCMFCDLLForm, FTabDllForm.Handle, 0, 0, FTabDllForm.Width, FTabDllForm.Height, SWP_NOZORDER OR SWP_NOACTIVATE); // 最大化 DLL 子窗体
  PostMessage(Application.MainForm.Handle, WM_NCACTIVATE, 1, 0);                                                                 // 激活主窗体
  UnHook(@FOld_CreateWindowExW);                                                                                                 // UNHOOK
  FOld_CreateWindowExW := nil;                                                                                                   // UNHOOK
end;

function HookCreateWindowExW(dwExStyle: DWORD; lpClassName: LPCWSTR; lpWindowName: LPCWSTR; dwStyle: DWORD; X, Y, nWidth, nHeight: Integer; hWndParent: hWnd; hMenu: hMenu; hins: HINST; lpp: Pointer): hWnd; stdcall;
begin
  { 是指定的 VC 窗体 }
  if (lpClassName <> nil) and (lpWindowName <> nil) and (SameText(lpClassName, FstrVCMFCDllClassName)) and (SameText(lpWindowName, FstrVCMFCDllWindowName)) then
  begin
    { 创建 VC MFC DLL 窗体。因为 MFC 窗体是在线程中创建的，所以这里不能加入任何 DELPHI 的代码，阻碍 VC 线程的执行 }
    Result         := FOld_CreateWindowExW(dwExStyle, lpClassName, lpWindowName, dwStyle xor WS_MINIMIZEBOX xor WS_MAXIMIZEBOX, X, Y, nWidth, nHeight, hWndParent, hMenu, hins, lpp);
    FhVCMFCDLLForm := Result;
  end
  else
  begin
    Result := FOld_CreateWindowExW(dwExStyle, lpClassName, lpWindowName, dwStyle, X, Y, nWidth, nHeight, hWndParent, hMenu, hins, lpp);
  end;
end;

procedure FindVCMFCDLLFormEnd(hWnd: hWnd; uMsg, idEvent: UINT; dwTime: DWORD); stdcall;
begin
  if FhVCMFCDllModule = 0 then
  begin
    KillTimer(Application.MainForm.Handle, c_intVCMFCDllFormEndTimerID);
    ShowVCMFCDllForm(FstrNewVCDLGDllFileName, FTabDllForm);
  end;
end;

{ 定时查看，VC MFC DLL Form 窗体是否被关闭 }
procedure FindMFCDllFormClose(hWnd: hWnd; uMsg, idEvent: UINT; dwTime: DWORD); stdcall;
begin
  FTabDllForm.PageControl.ActivePage := FTabDllForm; //
  if not IsWindowVisible(FhVCMFCDLLForm) then
  begin
    KillTimer(Application.MainForm.Handle, c_intVCMFCDllFormCloseTimerID);
    FreeLibrary(FhVCMFCDllModule);
    FhVCMFCDllModule        := 0;
    FhVCMFCDLLForm          := 0;
    FstrVCMFCDllClassName   := '';
    FstrVCMFCDllWindowName  := '';
    FstrBakVCMFCDllFileName := '';
    RestoreDefultTabSheet(FTabDllForm.PageControl);
  end;
end;

{ 查找 VC MFC DLL Form 的主窗体是否成功创建 }
procedure FindMFCDllFormCreate(hWnd: hWnd; uMsg, idEvent: UINT; dwTime: DWORD); stdcall;
begin
  if FhVCMFCDLLForm = 0 then
    Exit;

  KillTimer(Application.MainForm.Handle, c_intVCMFCDllFormCreateTimerID);                          // 销毁定时器
  CreateVCDllForm;                                                                                 // 创建 VC DLL 窗体
  ShowWindow(FhVCMFCDLLForm, SW_SHOW);                                                             // 显示 MFC DLL 窗体
  SetTimer(Application.MainForm.Handle, c_intVCMFCDllFormCloseTimerID, 200, @FindMFCDllFormClose); // 定时查看，MFC DLL 窗体是否被关闭
end;

{ 运行 VC MFC DLL Form 窗体 }
procedure ShowVCMFCDllForm(const strFileName: String; tsDll: TTabSheet);
var
  hDll                             : HMODULE;
  ShowVCDllForm                    : Tdb_ShowDllForm_Plugins_VCForm;
  strParamModuleName, strModuleName: PAnsiChar;
  strClassName, strWindowName      : PAnsiChar;
begin
  { 等待先前的 VC MFC DLL Form 模态窗体销毁完成，才能进行新的 DLL 创建 }
  if FhVCMFCDllModule <> 0 then
  begin
    FstrNewVCDLGDllFileName := strFileName;
    FTabDllForm             := tsDll;
    SetTimer(Application.MainForm.Handle, c_intVCMFCDllFormEndTimerID, 200, @FindVCMFCDLLFormEnd);
    Exit;
  end;

  if CompareText(FstrBakVCMFCDllFileName, strFileName) = 0 then
    Exit;

  FTabDllForm             := tsDll;
  FstrBakVCMFCDllFileName := strFileName;

  { 只获取参数，不调用显示窗体。下 HOOK，HOOK 指定窗体 }
  hDll := LoadLibrary(PChar(strFileName));
  try
    ShowVCDllForm := GetProcAddress(hDll, c_strDllExportFuncName);
    ShowVCDllForm(FLangStyle, strParamModuleName, strModuleName, strClassName, strWindowName, False);
    FstrVCMFCDllClassName  := String(strClassName);
    FstrVCMFCDllWindowName := String(strWindowName);
    HookProcInModule(user32, 'CreateWindowExW', @HookCreateWindowExW, @FOld_CreateWindowExW);
  finally
    FreeLibrary(hDll);
  end;

  { 加载 VC MFC DLL Form 非模态窗体 }
  FhVCMFCDLLForm   := 0;
  FhVCMFCDllModule := LoadLibrary(PChar(strFileName));
  ShowVCDllForm    := GetProcAddress(FhVCMFCDllModule, c_strDllExportFuncName);
  ShowVCDllForm(FLangStyle, strParamModuleName, strModuleName, strClassName, strWindowName, True);
  SetTimer(Application.MainForm.Handle, c_intVCMFCDllFormCreateTimerID, 200, @FindMFCDllFormCreate);
end;

{ 检查上一次创建的 VC MFC DLL Form 是否关闭 }
procedure CheckLastVCMFCDllClose;
begin
  if FhVCMFCDLLForm = 0 then
    Exit;

  { 发送关闭窗体命令 }
  PostMessage(FhVCMFCDLLForm, WM_SYSCOMMAND, SC_CLOSE, 0);
end;

end.
