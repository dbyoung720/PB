unit uCommon;

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.ShellAPI, Winapi.IpRtrMib, Winapi.TlHelp32, Winapi.ShlObj, Winapi.IpTypes, Winapi.ActiveX, Winapi.IpHlpApi, Winapi.ImageHlp, System.Win.Registry,
  System.IOUtils, System.Types, System.Math, System.SysUtils, System.StrUtils, System.Classes, System.IniFiles, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Data.Win.ADODB, Data.db;

procedure DelayTime(const intTime: Cardinal);

{ 根据窗体句柄获取窗体实例 }
function GetInstanceFromhWnd(const hWnd: Cardinal): TWinControl;

{ 获取 Delphi 窗体的 TApplication }
function GetMainFormApplication: TApplication;

{ 获取 Dll 子模块窗体图标 }
function GetDllModuleIconHandle(const strPModuleName, strSModuleName: String): THandle;

{ 获取 DLL 所在路径 }
function GetDllFilePath: String;

{ 获取 PBox 主窗体句柄 <非 Dll 窗体> }
function GetMainFormHandle: hWnd;

const
  c_strIniModuleSection = 'Module';
  c_strTitle            = 'PBox 基于 DLL 窗口的模块化开发平台 v5.0';
  c_strMsgTitle: PChar  = '系统提示：';

implementation

procedure DelayTime(const intTime: Cardinal);
var
  intST, intET: Cardinal;
begin
  intST := GetTickCount;
  while True do
  begin
    Application.ProcessMessages;
    intET := GetTickCount;
    if intET - intST >= intTime then
      Break;
  end;
end;

{ 根据窗体句柄获取窗体实例 }
function GetInstanceFromhWnd(const hWnd: Cardinal): TWinControl;
type
  PObjectInstance = ^TObjectInstance;

  TObjectInstance = packed record
    Code: Byte;            { 短跳转 $E8 }
    Offset: Integer;       { CalcJmpOffset(Instance, @Block^.Code); }
    Next: PObjectInstance; { MainWndProc 地址 }
    Self: Pointer;         { 控件对象地址 }
  end;
var
  wc: PObjectInstance;
begin
  Result := nil;
  wc     := Pointer(GetWindowLong(hWnd, GWL_WNDPROC));
  if wc <> nil then
  begin
    Result := wc.Self;
  end;
end;

type
  PAppInfo = ^TAppInfo;

  TAppInfo = record
    PID: DWORD;
    hWnd: NativeInt;
  end;

function _EnumApplicationProc(P_HWND: hWnd; LParam: LParam): Boolean; stdcall;
var
  PID         : DWORD;
  Buffer      : PAppInfo;
  chrClassName: array [0 .. 255] of Char;
  strClassName: String;
begin
  Result := True;
  Buffer := PAppInfo(LParam);

  GetWindowThreadProcessId(P_HWND, @PID);
  if Buffer^.PID <> PID then
  begin
    Result := True;
  end
  else
  begin
    GetClassName(P_HWND, chrClassName, 256);
    strClassName := chrClassName;
    if SameText(strClassName, 'TApplication') then
    begin
      Result       := False;
      Buffer^.hWnd := P_HWND;
    end;
  end;
end;

{ 获取 Delphi 窗体的 TApplication }
function GetMainFormApplication: TApplication;
var
  Buffer   : TAppInfo;
  appHandle: THandle;
begin
  Result      := nil;
  Buffer.PID  := GetCurrentProcessId;
  Buffer.hWnd := 0;
  EnumWindows(@_EnumApplicationProc, Winapi.Windows.LParam(@Buffer));
  if Buffer.hWnd > 0 then
  begin
    appHandle := Buffer.hWnd;
    Result    := TApplication(GetInstanceFromhWnd(appHandle));
  end;
end;

{ 获取 Dll 子模块窗体图标 }
function GetDllModuleIconHandle(const strPModuleName, strSModuleName: String): THandle;
var
  strIconFilePath: String;
  strIconFileName: String;
  IcoExe         : TIcon;
begin
  Result := GetMainFormApplication.Icon.Handle;

  with TIniFile.Create(ChangeFileExt(ParamStr(0), '.ini')) do
  begin
    try
      strIconFilePath := ReadString(c_strIniModuleSection, Format('%s_%s_ICON', [strPModuleName, strSModuleName]), '');
      if strIconFilePath = '' then
        Exit;

      strIconFileName := ExtractFilePath(ParamStr(0)) + 'Plugins\Icon\' + strIconFilePath;
      if not FileExists(strIconFileName) then
        Exit;

      IcoExe := TIcon.Create;
      IcoExe.LoadFromFile(strIconFileName);
      Result := IcoExe.Handle;
    finally
      Free;
    end;
  end;
end;

{ 获取 DLL 模块文件名，包含路径 }
function GetDllFullFileName: String;
var
  strFileName: array [0 .. 255] of Char;
begin
  GetModuleFileName(HInstance, strFileName, 256);
  Result := strFileName;
end;

{ 获取 DLL 所在路径 }
function GetDllFilePath: String;
begin
  Result := ExtractFilePath(GetDllFullFileName);
end;

function _EnumWindowsProc(P_HWND: Cardinal; LParam: Cardinal): Boolean; stdcall;
var
  PID         : DWORD;
  chrClassName: array [0 .. 255] of Char;
  strClassName: String;
begin
  Result := True;

  GetWindowThreadProcessId(P_HWND, @PID);
  if PCardinal(LParam)^ <> PID then
  begin
    Result := True;
  end
  else
  begin
    GetClassName(P_HWND, chrClassName, 256);
    strClassName := chrClassName;
    if                                                                  //
      (CompareText(strClassName, 'TApplication') <> 0) and              //
      (CompareText(strClassName, 'TPUtilWindow') <> 0) and              //
      (CompareText(strClassName, 'IME') <> 0) and                       //
      (CompareText(strClassName, 'MSCTFIME UI') <> 0) and               //
      (CompareText(strClassName, 'tooltips_class32') <> 0) and          //
      (CompareText(strClassName, 'ADODB.AsyncEventMessenger') <> 0) and //
      (CompareText(strClassName, 'TfrmSQL') <> 0)                       //
    then
    begin
      Result                 := False;
      PCardinal(LParam + 4)^ := P_HWND;
    end;
  end;
end;

{ 获取 PBox 主窗体句柄 <非 Dll 窗体> }
function GetMainFormHandle: hWnd;
var
  Buffer: array [0 .. 1] of Cardinal;
begin
  Result    := 0;
  Buffer[0] := GetCurrentProcessId;
  Buffer[1] := 0;
  EnumWindows(@_EnumWindowsProc, Integer(@Buffer));
  if Buffer[1] > 0 then
    Result := Buffer[1];
end;

end.
