unit uDllDelphi;
{
  Func : Delphi Dll Form Create / Free Manager
  Auth : dbyoung@sina.com
  Time : 2023-02-10
}

interface

uses Winapi.Windows, Winapi.Messages, System.SysUtils, Vcl.Controls, Vcl.Forms, Vcl.Graphics, Vcl.ComCtrls, uBaseForm;

{ ���� Delphi Dll Form }
procedure ShowDelphiDllForm(const strFileName: string; TabDll: TTabSheet);

{ �����һ�δ����� Delphi Dll Form �Ƿ�ر� }
procedure CheckLastDelphiDllClose;

implementation

var
  FfrmDelphiDll: TForm = nil;
  FTabDll      : TTabSheet;

procedure DLog(const strLog: String);
begin
  OutputDebugString(PChar(Format('%s  %s', [FormatDateTime('yyyy-MM-dd hh:mm:ss', Now), strLog])));
end;

{ ���� Delphi Dll Form �Ƿ񱻹ر� }
procedure FindDelphiDllFormClose(hWnd: THandle; uMsg, idEvent: UINT; dwTime: DWORD); stdcall;
var
  hDllMod: HMODULE;
begin
  FTabDll.PageControl.ActivePage := FTabDll;
  if not IsWindowVisible(FfrmDelphiDll.Handle) then
  begin
    KillTimer(Application.MainForm.Handle, c_intDelphiDllFormCloseTimerID);
    hDllMod := FfrmDelphiDll.Tag;
    FfrmDelphiDll.Free;
    FfrmDelphiDll := nil;
    FreeLibrary(hDllMod);
    RestoreDefultTabSheet(FTabDll.PageControl);
  end;
end;

{ ���� Delphi Dll Form }
procedure ShowDelphiDllForm(const strFileName: string; TabDll: TTabSheet);
var
  hDllMod                           : HMODULE;
  frmDll                            : TFormClass;
  DllDelphi                         : Tdb_ShowDllForm_Plugins_Delphi;
  strParentModuleName, strModuleName: PAnsiChar;
begin
  FTabDll                       := TabDll;
  TabDll.PageControl.ActivePage := TabDll;
  hDllMod                       := LoadLibrary(PChar(strFileName));
  DllDelphi                     := GetProcaddress(hDllMod, c_strDllExportFuncName);
  DllDelphi(frmDll, strParentModuleName, strModuleName);
  FfrmDelphiDll             := frmDll.Create(nil);
  FfrmDelphiDll.BorderIcons := [biSystemMenu];
  FfrmDelphiDll.Position    := poDesigned;
  FfrmDelphiDll.BorderStyle := bsSingle;
  FfrmDelphiDll.Color       := clWhite;
  FfrmDelphiDll.Tag         := hDllMod;
  FfrmDelphiDll.Anchors     := [akLeft, akTop, akRight, akBottom];
  RemoveMenu(GetSystemMenu(FfrmDelphiDll.Handle, False), 0, MF_BYPOSITION);                                             // ɾ���ƶ��˵�
  RemoveMenu(GetSystemMenu(FfrmDelphiDll.Handle, False), 0, MF_BYPOSITION);                                             // ɾ����С�˵�
  RemoveMenu(GetSystemMenu(FfrmDelphiDll.Handle, False), 0, MF_BYPOSITION);                                             // ɾ����С���˵�
  RemoveMenu(GetSystemMenu(FfrmDelphiDll.Handle, False), 0, MF_BYPOSITION);                                             // ɾ����󻯲˵�
  RemoveMenu(GetSystemMenu(FfrmDelphiDll.Handle, False), 0, MF_BYPOSITION);                                             // ɾ���ָ��߲˵�
  RemoveMenu(GetSystemMenu(FfrmDelphiDll.Handle, False), 0, MF_BYPOSITION);                                             // ɾ���ƶ��˵�
  RemoveCaption(FfrmDelphiDll.Handle);                                                                                  // ȥ��������
  SetWindowPos(FfrmDelphiDll.Handle, TabDll.Handle, 0, 0, TabDll.Width, TabDll.Height, SWP_NOZORDER OR SWP_NOACTIVATE); // ��� Dll �Ӵ���
  Winapi.Windows.SetParent(FfrmDelphiDll.Handle, TabDll.Handle);                                                        // ���ø�����Ϊ TabSheet
  FfrmDelphiDll.Show;                                                                                                   // ��ʾ Dll �Ӵ���
  SetTimer(Application.MainForm.Handle, c_intDelphiDllFormCloseTimerID, 200, @FindDelphiDllFormClose);                  // ���� Delphi Dll Form �Ƿ񱻹ر�
end;

{ �����һ�δ����� Delphi Dll Form �Ƿ�ر� }
procedure CheckLastDelphiDllClose;
begin
  if not Assigned(FfrmDelphiDll) then
    Exit;

  PostMessage(FfrmDelphiDll.Handle, WM_CLOSE, 0, 0);

  while True do
  begin
    Application.ProcessMessages;
    if FfrmDelphiDll = nil then
      Break;
  end;
end;

end.
