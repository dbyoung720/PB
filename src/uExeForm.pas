unit uExeForm;
{
  Func : EXE Form Create / Free Manager
  Auth : dbyoung@sina.com
  Time : 2023-02-15
}

interface

uses Winapi.Windows, Winapi.ShellAPI, System.Win.Registry, System.Classes, System.SysUtils, System.StrUtils, Vcl.Forms, Vcl.ComCtrls, uBaseForm;

{ ���� EXE Form }
procedure ShowEXEForm(const strFileName, strExeFormClassName, strExeFormTitleName: string; TabDll: TTabsheet);

{ �����һ�δ����� EXE Form �Ƿ�ر� }
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

{ ���� EXE �Ƿ񱻹ر� }
procedure FindExeFormClose(hWnd: THandle; uMsg, idEvent: UINT; dwTime: DWORD); stdcall;
begin
  if FhEXEFormHandle = 0 then
    Exit;

  { ���屻�ر��ˣ��Ƿ���� }
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

{ ���� EXE ���������Ƿ�ɹ����� }
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

  { ���ĵ�������������С����󻯣��������ı��ǲ�һ���� }
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

  { �� EXE ��������õ� Tab Dll ������ }
  SetParentForm(hEXEFormHandle, FTabSheet, intPID);

  { ���� EXE �Ƿ񱻹ر� }
  SetTimer(Application.MainForm.Handle, c_intEXEFormCloseTimerID, 200, @FindExeFormClose);
end;

{ ���� EXE Form }
procedure ShowEXEForm(const strFileName, strExeFormClassName, strExeFormTitleName: string; TabDll: TTabsheet);
begin
  FTabSheet                        := TabDll;
  FTabSheet.PageControl.ActivePage := FTabSheet;
  FstrEXEFormClassName             := strExeFormClassName;
  FstrEXEFormTitleName             := strExeFormTitleName;

  { ���� EXE ���������Ƿ�ɹ����� }
  SetTimer(Application.MainForm.Handle, c_intEXEFormCreateTimerID, 200, @FindExeFormCreate);

  { ɾ����������ļ��й��ڴ���λ�õ�������Ϣ }
  CheckPlugInConfigSize;

  { ��� Sysinternals ������ }
  CheckSysinternalsAllow(strFileName);

  { ���� EXE ���̣������ش��� }
  ShellExecute(Application.MainForm.Handle, 'Open', PChar(strFileName), nil, nil, SW_HIDE);
end;

{ �����һ�δ����� EXE Form �Ƿ�ر� }
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

  { ���ٿ��ܴ��ڵļ�ʱ�� }
  KillTimer(Application.MainForm.Handle, c_intEXEFormCreateTimerID);
  KillTimer(Application.MainForm.Handle, c_intEXEFormCloseTimerID);

  { ������λ }
  FstrEXEFormClassName := '';
  FstrEXEFormTitleName := '';
  FhEXEFormHandle      := 0;
  RestoreDefultTabSheet(FTabSheet.PageControl);

  { ɱ������ }
  hProcess := OpenProcess(PROCESS_TERMINATE, False, intPID);
  TerminateProcess(hProcess, 0);
end;

end.
