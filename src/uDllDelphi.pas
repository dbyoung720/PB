unit uDllDelphi;
{
  Func : Delphi Dll Form Create / Free Manager
  Auth : dbyoung@sina.com
  Time : 2023-02-10
}

interface

uses Winapi.Windows, Winapi.Messages, System.SysUtils, Vcl.Controls, Vcl.Forms, Vcl.Graphics, Vcl.ComCtrls, uBaseForm;

{ 创建 Delphi Dll Form }
procedure ShowDelphiDllForm(const strFileName: string; TabDll: TTabSheet);

{ 检查上一次创建的 Delphi Dll Form 是否关闭 }
procedure CheckLastDelphiDllClose;

implementation

var
  FfrmDelphiDll: TForm = nil;
  FTabDll      : TTabSheet;

procedure DLog(const strLog: String);
begin
  OutputDebugString(PChar(Format('%s  %s', [FormatDateTime('yyyy-MM-dd hh:mm:ss', Now), strLog])));
end;

{ 查找 Delphi Dll Form 是否被关闭 }
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

{ 创建 Delphi Dll Form }
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
  RemoveMenu(GetSystemMenu(FfrmDelphiDll.Handle, False), 0, MF_BYPOSITION);                                             // 删除移动菜单
  RemoveMenu(GetSystemMenu(FfrmDelphiDll.Handle, False), 0, MF_BYPOSITION);                                             // 删除大小菜单
  RemoveMenu(GetSystemMenu(FfrmDelphiDll.Handle, False), 0, MF_BYPOSITION);                                             // 删除最小化菜单
  RemoveMenu(GetSystemMenu(FfrmDelphiDll.Handle, False), 0, MF_BYPOSITION);                                             // 删除最大化菜单
  RemoveMenu(GetSystemMenu(FfrmDelphiDll.Handle, False), 0, MF_BYPOSITION);                                             // 删除分割线菜单
  RemoveMenu(GetSystemMenu(FfrmDelphiDll.Handle, False), 0, MF_BYPOSITION);                                             // 删除移动菜单
  RemoveCaption(FfrmDelphiDll.Handle);                                                                                  // 去除标题栏
  SetWindowPos(FfrmDelphiDll.Handle, TabDll.Handle, 0, 0, TabDll.Width, TabDll.Height, SWP_NOZORDER OR SWP_NOACTIVATE); // 最大化 Dll 子窗体
  Winapi.Windows.SetParent(FfrmDelphiDll.Handle, TabDll.Handle);                                                        // 设置父窗体为 TabSheet
  FfrmDelphiDll.Show;                                                                                                   // 显示 Dll 子窗体
  SetTimer(Application.MainForm.Handle, c_intDelphiDllFormCloseTimerID, 200, @FindDelphiDllFormClose);                  // 查找 Delphi Dll Form 是否被关闭
end;

{ 检查上一次创建的 Delphi Dll Form 是否关闭 }
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
