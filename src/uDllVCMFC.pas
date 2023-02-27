unit uDllVCMFC;
{
  Func : VC MFC DLL Form Create / Free Manager
  Auth : dbyoung@sina.com
  Time : 2023-02-10
}

interface

uses Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Forms, Vcl.ComCtrls, HookUtils, uBaseForm;

{ ���� VC MFC DLL ���� }
procedure ShowVCMFCDllForm(const strFileName: String; tsDll: TTabSheet);

{ �����һ�δ����� VC MFC DLL Form �Ƿ�ر� }
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

{ ���� VC DLL ���� }
procedure CreateVCDllForm;
begin
  FTabDllForm.PageControl.ActivePage := FTabDllForm;                                                                             //
  Winapi.Windows.SetParent(FhVCMFCDLLForm, FTabDllForm.Handle);                                                                  // ���ø�����Ϊ TabSheet
  RemoveMenu(GetSystemMenu(FhVCMFCDLLForm, False), 0, MF_BYPOSITION);                                                            // ɾ���ƶ��˵�
  RemoveMenu(GetSystemMenu(FhVCMFCDLLForm, False), 0, MF_BYPOSITION);                                                            // ɾ���ƶ��˵�
  RemoveMenu(GetSystemMenu(FhVCMFCDLLForm, False), 0, MF_BYPOSITION);                                                            // ɾ���ƶ��˵�
  RemoveMenu(GetSystemMenu(FhVCMFCDLLForm, False), 0, MF_BYPOSITION);                                                            // ɾ���ƶ��˵�
  RemoveMenu(GetSystemMenu(FhVCMFCDLLForm, False), 0, MF_BYPOSITION);                                                            // ɾ���ƶ��˵�
  RemoveMenu(GetSystemMenu(FhVCMFCDLLForm, False), 0, MF_BYPOSITION);                                                            // ɾ���ƶ��˵�
  RemoveCaption(FhVCMFCDLLForm);                                                                                                 // ȥ��������
  SetWindowPos(FhVCMFCDLLForm, FTabDllForm.Handle, 0, 0, FTabDllForm.Width, FTabDllForm.Height, SWP_NOZORDER OR SWP_NOACTIVATE); // ��� DLL �Ӵ���
  PostMessage(Application.MainForm.Handle, WM_NCACTIVATE, 1, 0);                                                                 // ����������
  UnHook(@FOld_CreateWindowExW);                                                                                                 // UNHOOK
  FOld_CreateWindowExW := nil;                                                                                                   // UNHOOK
end;

function HookCreateWindowExW(dwExStyle: DWORD; lpClassName: LPCWSTR; lpWindowName: LPCWSTR; dwStyle: DWORD; X, Y, nWidth, nHeight: Integer; hWndParent: hWnd; hMenu: hMenu; hins: HINST; lpp: Pointer): hWnd; stdcall;
begin
  { ��ָ���� VC ���� }
  if (lpClassName <> nil) and (lpWindowName <> nil) and (SameText(lpClassName, FstrVCMFCDllClassName)) and (SameText(lpWindowName, FstrVCMFCDllWindowName)) then
  begin
    { ���� VC MFC DLL ���塣��Ϊ MFC ���������߳��д����ģ��������ﲻ�ܼ����κ� DELPHI �Ĵ��룬�谭 VC �̵߳�ִ�� }
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

{ ��ʱ�鿴��VC MFC DLL Form �����Ƿ񱻹ر� }
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

{ ���� VC MFC DLL Form ���������Ƿ�ɹ����� }
procedure FindMFCDllFormCreate(hWnd: hWnd; uMsg, idEvent: UINT; dwTime: DWORD); stdcall;
begin
  if FhVCMFCDLLForm = 0 then
    Exit;

  KillTimer(Application.MainForm.Handle, c_intVCMFCDllFormCreateTimerID);                          // ���ٶ�ʱ��
  CreateVCDllForm;                                                                                 // ���� VC DLL ����
  ShowWindow(FhVCMFCDLLForm, SW_SHOW);                                                             // ��ʾ MFC DLL ����
  SetTimer(Application.MainForm.Handle, c_intVCMFCDllFormCloseTimerID, 200, @FindMFCDllFormClose); // ��ʱ�鿴��MFC DLL �����Ƿ񱻹ر�
end;

{ ���� VC MFC DLL Form ���� }
procedure ShowVCMFCDllForm(const strFileName: String; tsDll: TTabSheet);
var
  hDll                             : HMODULE;
  ShowVCDllForm                    : Tdb_ShowDllForm_Plugins_VCForm;
  strParamModuleName, strModuleName: PAnsiChar;
  strClassName, strWindowName      : PAnsiChar;
begin
  { �ȴ���ǰ�� VC MFC DLL Form ģ̬����������ɣ����ܽ����µ� DLL ���� }
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

  { ֻ��ȡ��������������ʾ���塣�� HOOK��HOOK ָ������ }
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

  { ���� VC MFC DLL Form ��ģ̬���� }
  FhVCMFCDLLForm   := 0;
  FhVCMFCDllModule := LoadLibrary(PChar(strFileName));
  ShowVCDllForm    := GetProcAddress(FhVCMFCDllModule, c_strDllExportFuncName);
  ShowVCDllForm(FLangStyle, strParamModuleName, strModuleName, strClassName, strWindowName, True);
  SetTimer(Application.MainForm.Handle, c_intVCMFCDllFormCreateTimerID, 200, @FindMFCDllFormCreate);
end;

{ �����һ�δ����� VC MFC DLL Form �Ƿ�ر� }
procedure CheckLastVCMFCDllClose;
begin
  if FhVCMFCDLLForm = 0 then
    Exit;

  { ���͹رմ������� }
  PostMessage(FhVCMFCDLLForm, WM_SYSCOMMAND, SC_CLOSE, 0);
end;

end.
