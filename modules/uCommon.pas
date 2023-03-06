unit uCommon;

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.ShellAPI, Winapi.IpRtrMib, Winapi.TlHelp32, Winapi.ShlObj, Winapi.IpTypes, Winapi.ActiveX, Winapi.IpHlpApi, Winapi.ImageHlp, System.Win.Registry,
  System.IOUtils, System.Types, System.Math, System.SysUtils, System.StrUtils, System.Classes, System.IniFiles, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Data.Win.ADODB, Data.db, CnAES;

procedure DelayTime(const intTime: Cardinal);

{ ���ݴ�������ȡ����ʵ�� }
function GetInstanceFromhWnd(const hWnd: Cardinal): TWinControl;

{ ��ȡ Delphi ����� TApplication }
function GetMainFormApplication: TApplication;

{ ��ȡ Dll ��ģ�鴰��ͼ�� }
function GetDllModuleIconHandle(const strPModuleName, strSModuleName: String): THandle;

{ ��ȡ DLL ����·�� }
function GetDllFilePath: String;

{ ��ȡ PBox �������� <�� Dll ����> }
function GetMainFormHandle: hWnd;

{ �����ַ��� }
function EncryptString(const strTemp, strKey: string): String;

{ �����ַ��� }
function DecryptString(const strTemp, strKey: string): String;

const
  c_strIniModuleSection = 'Module';
  c_strTitle            = 'PBox ���� DLL ���ڵ�ģ�黯����ƽ̨ v5.0';
  c_strMsgTitle: PChar  = 'ϵͳ��ʾ��';
  c_strAESKEY           = 'dbyoung@sina.com';

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

{ ���ݴ�������ȡ����ʵ�� }
function GetInstanceFromhWnd(const hWnd: Cardinal): TWinControl;
type
  PObjectInstance = ^TObjectInstance;

  TObjectInstance = packed record
    Code: Byte;            { ����ת $E8 }
    Offset: Integer;       { CalcJmpOffset(Instance, @Block^.Code); }
    Next: PObjectInstance; { MainWndProc ��ַ }
    Self: Pointer;         { �ؼ������ַ }
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

{ ��ȡ Delphi ����� TApplication }
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

{ ��ȡ Dll ��ģ�鴰��ͼ�� }
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

{ ��ȡ DLL ģ���ļ���������·�� }
function GetDllFullFileName: String;
var
  strFileName: array [0 .. 255] of Char;
begin
  GetModuleFileName(HInstance, strFileName, 256);
  Result := strFileName;
end;

{ ��ȡ DLL ����·�� }
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

{ ��ȡ PBox �������� <�� Dll ����> }
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

{ �����ַ��� }
function EncryptString(const strTemp, strKey: string): String;
begin
  Result := string(AESEncryptEcbStrToHex(AnsiString(strTemp), AnsiString(strKey)));
end;

{ �����ַ��� }
function DecryptString(const strTemp, strKey: string): String;
begin
  Result := string(AESDecryptEcbStrFromHex(AnsiString(strTemp), AnsiString(strKey)));
end;

end.
