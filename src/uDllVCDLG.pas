unit uDllVCDLG;
{
  Func : VC DLG DLL Form Create / Free Manager
  Auth : dbyoung@sina.com
  Time : 2023-02-10
}

interface

uses Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Forms, Vcl.ComCtrls, HookUtils, uBaseForm;

{ ���� VC DLG DLL Form ���� }
procedure ShowVCDLGDllForm(const strVCDllFileName: String; tsDll: TTabSheet);

{ �����һ�δ����� VC DLG DLL Form �Ƿ�ر� }
procedure CheckLastVCDLGDllClose;

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

procedure DLog(const strLog: String);
begin
  OutputDebugString(PChar(Format('%s  %s', [FormatDateTime('yyyy-MM-dd hh:mm:ss', Now), strLog])));
end;

{ ���� VC DLL ���� }
procedure CreateVCDllForm;
begin
  FTabDllForm.PageControl.ActivePage := FTabDllForm;                                                                             //
  Winapi.Windows.SetParent(FhVCDLGDLLForm, FTabDllForm.Handle);                                                                  // ���ø�����Ϊ TabSheet
  RemoveMenu(GetSystemMenu(FhVCDLGDLLForm, False), 0, MF_BYPOSITION);                                                            // ɾ���ƶ��˵�
  RemoveMenu(GetSystemMenu(FhVCDLGDLLForm, False), 0, MF_BYPOSITION);                                                            // ɾ���ƶ��˵�
  RemoveMenu(GetSystemMenu(FhVCDLGDLLForm, False), 0, MF_BYPOSITION);                                                            // ɾ���ƶ��˵�
  RemoveMenu(GetSystemMenu(FhVCDLGDLLForm, False), 0, MF_BYPOSITION);                                                            // ɾ���ƶ��˵�
  RemoveMenu(GetSystemMenu(FhVCDLGDLLForm, False), 0, MF_BYPOSITION);                                                            // ɾ���ƶ��˵�
  RemoveMenu(GetSystemMenu(FhVCDLGDLLForm, False), 0, MF_BYPOSITION);                                                            // ɾ���ƶ��˵�
  RemoveCaption(FhVCDLGDLLForm);                                                                                                 // ȥ��������
  SetWindowPos(FhVCDLGDLLForm, FTabDllForm.Handle, 0, 0, FTabDllForm.Width, FTabDllForm.Height, SWP_NOZORDER OR SWP_NOACTIVATE); // ��� DLL �Ӵ���
  PostMessage(Application.MainForm.Handle, WM_NCACTIVATE, 1, 0);                                                                 // ����������
  UnHook(@FOld_CreateWindowExW);                                                                                                 // UNHOOK
  FOld_CreateWindowExW := nil;                                                                                                   // UNHOOK
end;

function HookCreateWindowExW(dwExStyle: DWORD; lpClassName: LPCWSTR; lpWindowName: LPCWSTR; dwStyle: DWORD; X, Y, nWidth, nHeight: Integer; hWndParent: hWnd; hMenu: hMenu; hins: HINST; lpp: Pointer): hWnd; stdcall;
begin
  { ��ָ���� VC ���� }
  if (lpClassName <> nil) and (lpWindowName <> nil) and (SameText(lpClassName, FstrVCDLGDllClassName)) and (SameText(lpWindowName, FstrVCDLGDllWindowName)) then
  begin
    { ���� VC DLG DLL Form ���� }
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

{ ���� VC DLG DLL Form ���� }
procedure ShowVCDLGDllForm(const strVCDllFileName: String; tsDll: TTabSheet);
var
  hDll                             : HMODULE;
  ShowVCDllForm                    : Tdb_ShowDllForm_Plugins_VCForm;
  strParamModuleName, strModuleName: PAnsiChar;
  strClassName, strWindowName      : PAnsiChar;
begin
  { �ȴ���ǰ�� VC DLG DLL Form ģ̬����������ɣ����ܽ����µ� DLL ���� }
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

  { ֻ��ȡ��������������ʾ���塣�� HOOK��HOOK ָ������ }
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

  { ���� VC DLG Dll Form ģ̬���壻����رռ��ͷ� }
  FhVCDLGDllModule := LoadLibrary(PChar(strVCDllFileName));
  ShowVCDllForm    := GetProcAddress(FhVCDLGDllModule, c_strDllExportFuncName);
  ShowVCDllForm(FLangStyle, strParamModuleName, strModuleName, strClassName, strWindowName, True);

  { ȫ�ֱ�����λ }
  FreeLibrary(FhVCDLGDllModule);
  FhVCDLGDllModule        := 0;
  FhVCDLGDLLForm          := 0;
  FstrVCDLGDllClassName   := '';
  FstrVCDLGDllWindowName  := '';
  FstrBakVCDLGDllFileName := '';
  RestoreDefultTabSheet(tsDll.PageControl);
end;

{ �����һ�δ����� VC DLG DLL Form �Ƿ�ر� }
procedure CheckLastVCDLGDllClose;
begin
  if FhVCDLGDLLForm = 0 then
    Exit;

  { ���͹رմ������� }
  PostMessage(FhVCDLGDLLForm, WM_SYSCOMMAND, SC_CLOSE, 0);
end;

end.
