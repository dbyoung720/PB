unit uExeForm;
{
  Func : EXE Form Create / Free Manager
  Auth : dbyoung@sina.com
  Time : 2023-02-15
}

interface

uses Winapi.Windows, Winapi.ShellAPI, System.Win.Registry, System.Classes, System.SysUtils, System.StrUtils, Vcl.Forms, Vcl.ComCtrls, uBaseForm;

{ 创建 EXE Form }
procedure ShowEXEForm(const strFileName, strExeFormClassName, strExeFormTitleName: string; TabDll: TTabsheet);

{ 检查上一次创建的 EXE Form 是否关闭 }
procedure CheckLastExeFormClose();

implementation

var
  FTabSheet           : TTabsheet = nil;
  FstrEXEFormClassName: string    = '';
  FstrEXEFormTitleName: string    = '';
  FhEXEFormHandle     : THandle   = 0;

procedure DLog(const strLog: String);
begin
  OutputDebugString(PChar(Format('%s  %s', [FormatDateTime('yyyy-MM-dd hh:mm:ss', Now), strLog])));
end;

{ 查找 EXE 是否被关闭 }
procedure FindExeFormClose(hWnd: THandle; uMsg, idEvent: UINT; dwTime: DWORD); stdcall;
begin
  if FhEXEFormHandle = 0 then
    Exit;

  { 窗体被关闭了，是否变量 }
  FTabSheet.PageControl.ActivePage := FTabSheet;
  if not IsWindowVisible(FhEXEFormHandle) then
  begin
    KillTimer(Application.MainForm.Handle, c_intEXEFormCloseTimerID);
    FstrEXEFormClassName := '';
    FstrEXEFormTitleName := '';
    FhEXEFormHandle      := 0;
    RestoreDefultTabSheet(FTabSheet.PageControl);
  end;
end;

{ 查找 EXE 的主窗体是否成功创建 }
procedure FindExeFormCreate(hWnd: THandle; uMsg, idEvent: UINT; dwTime: DWORD); stdcall;
var
  hEXEFormHandle: THandle;
  intPID        : DWORD;
  strTitleName  : String;
  intIndex      : Integer;
begin
  if (Trim(FstrEXEFormClassName) = '') and (Trim(FstrEXEFormTitleName) <> '') then
    hEXEFormHandle := FindWindow(nil, PChar(FstrEXEFormTitleName))
  else if (Trim(FstrEXEFormClassName) <> '') and (Trim(FstrEXEFormTitleName) = '') then
    hEXEFormHandle := FindWindow(PChar(FstrEXEFormClassName), nil)
  else
    hEXEFormHandle := FindWindow(PChar(FstrEXEFormClassName), PChar(FstrEXEFormTitleName));

  { 多文档，窗体正常大小和最大化，标题栏文本是不一样的 }
  if hEXEFormHandle = 0 then
  begin
    intIndex := Pos('windows', LowerCase(FstrEXEFormTitleName));
    if intIndex > 0 then
    begin
      strTitleName := Leftstr(FstrEXEFormTitleName, intIndex - 1) + '[' + 'Windows' + RightStr(FstrEXEFormTitleName, Length(FstrEXEFormTitleName) - intIndex - 6) + ']';
      if Trim(FstrEXEFormClassName) = '' then
        hEXEFormHandle := FindWindow(nil, PChar(strTitleName))
      else
        hEXEFormHandle := FindWindow(PChar(FstrEXEFormClassName), PChar(strTitleName));
    end;
  end;

  if hEXEFormHandle = 0 then
  begin
    intIndex := Pos('[windows', LowerCase(FstrEXEFormTitleName));
    if intIndex > 0 then
    begin
      strTitleName := Leftstr(FstrEXEFormTitleName, intIndex - 1) + 'Windows ' + MidStr(FstrEXEFormTitleName, intIndex + 9, 1);
      if Trim(FstrEXEFormClassName) = '' then
        hEXEFormHandle := FindWindow(nil, PChar(strTitleName))
      else
        hEXEFormHandle := FindWindow(PChar(FstrEXEFormClassName), PChar(strTitleName));
    end;
  end;

  if hEXEFormHandle = 0 then
    Exit;

  KillTimer(Application.MainForm.Handle, c_intEXEFormCreateTimerID);
  DelayTime(200);
  GetWindowThreadProcessId(hEXEFormHandle, intPID);
  FhEXEFormHandle := hEXEFormHandle;

  { 将 EXE 主窗体放置到 Tab Dll 窗口中 }
  SetParentForm(hEXEFormHandle, FTabSheet, intPID);

  { 查找 EXE 是否被关闭 }
  SetTimer(Application.MainForm.Handle, c_intEXEFormCloseTimerID, 200, @FindExeFormClose);
end;

{ 创建 EXE Form }
procedure ShowEXEForm(const strFileName, strExeFormClassName, strExeFormTitleName: string; TabDll: TTabsheet);
begin
  FTabSheet                        := TabDll;
  FTabSheet.PageControl.ActivePage := FTabSheet;
  FstrEXEFormClassName             := strExeFormClassName;
  FstrEXEFormTitleName             := strExeFormTitleName;

  { 查找 EXE 的主窗体是否成功创建 }
  SetTimer(Application.MainForm.Handle, c_intEXEFormCreateTimerID, 200, @FindExeFormCreate);

  { 删除插件配置文件中关于窗体位置的配置信息 }
  CheckPlugInConfigSize;

  { 检查 Sysinternals 软件许可 }
  CheckSysinternalsAllow(strFileName);

  { 创建 EXE 进程，并隐藏窗体 }
  ShellExecute(Application.MainForm.Handle, 'Open', PChar(strFileName), nil, nil, SW_HIDE);
end;

{ 检查上一次创建的 EXE Form 是否关闭 }
procedure CheckLastExeFormClose();
var
  intPID  : DWORD;
  hProcess: Cardinal;
begin
  if FhEXEFormHandle = 0 then
    Exit;

  FTabSheet.PageControl.ActivePage := FTabSheet;
  if not IsWindowVisible(FhEXEFormHandle) then
    Exit;

  GetWindowThreadProcessId(FhEXEFormHandle, intPID);
  if intPID <= 0 then
    Exit;

  { 销毁可能存在的计时器 }
  KillTimer(Application.MainForm.Handle, c_intEXEFormCreateTimerID);
  KillTimer(Application.MainForm.Handle, c_intEXEFormCloseTimerID);

  { 变量复位 }
  FstrEXEFormClassName := '';
  FstrEXEFormTitleName := '';
  FhEXEFormHandle      := 0;
  RestoreDefultTabSheet(FTabSheet.PageControl);

  { 杀死进程 }
  hProcess := OpenProcess(PROCESS_TERMINATE, False, intPID);
  TerminateProcess(hProcess, 0);
end;

end.
