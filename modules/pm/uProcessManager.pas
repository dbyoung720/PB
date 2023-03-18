unit uProcessManager;
{$WARN UNIT_PLATFORM OFF}

interface

uses
  Winapi.Windows, Winapi.ShlObj, Winapi.ShellAPI, Winapi.ActiveX, Winapi.TlHelp32, Winapi.PsAPI, System.SysUtils, System.Classes, System.IniFiles, System.Math, System.StrUtils,
  Vcl.Clipbrd, Vcl.FileCtrl, Vcl.Controls, Vcl.Forms, Vcl.ComCtrls, Vcl.Menus, Vcl.StdCtrls, Vcl.Dialogs, Vcl.Graphics,
  uProcessAPI, uScrollBar, uCommon;

type
  TfrmProcessManager = class(TForm)
    lvProcess: TListView;
    lvModule: TListView;
    pmProcess: TPopupMenu;
    mniOpenProcessPath: TMenuItem;
    mniRenameProcessName: TMenuItem;
    mniDeleteProcessFile: TMenuItem;
    mniDllInsertProcess: TMenuItem;
    mniLine01: TMenuItem;
    mniLoadPE: TMenuItem;
    pmModule: TPopupMenu;
    mniOpenModulePath: TMenuItem;
    mniEjectFromProcess: TMenuItem;
    mniDumpToDiskFile: TMenuItem;
    mniLine02: TMenuItem;
    mniCopySelectedModulePath: TMenuItem;
    mniCopySelectedModuleName: TMenuItem;
    mniCopySelectedModuleMemoryAddress: TMenuItem;
    mniLine03: TMenuItem;
    mniCopyFileTo: TMenuItem;
    mniSaveToFile: TMenuItem;
    mniSelectedLineToSaveFile: TMenuItem;
    mniKillProcess: TMenuItem;
    edtParam: TEdit;
    dlgOpenDll: TOpenDialog;
    dlgSaveEXE: TSaveDialog;
    mniProcessDump: TMenuItem;
    dlgSaveModuleInfo: TSaveDialog;
    mniFileAttr: TMenuItem;
    mniOpenModuleFileAtti: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure lvProcessClick(Sender: TObject);
    procedure lvProcessColumnClick(Sender: TObject; Column: TListColumn);
    procedure mniOpenProcessPathClick(Sender: TObject);
    procedure mniRenameProcessNameClick(Sender: TObject);
    procedure mniDeleteProcessFileClick(Sender: TObject);
    procedure mniDllInsertProcessClick(Sender: TObject);
    procedure mniLoadPEClick(Sender: TObject);
    procedure mniOpenModulePathClick(Sender: TObject);
    procedure mniEjectFromProcessClick(Sender: TObject);
    procedure mniDumpToDiskFileClick(Sender: TObject);
    procedure mniCopySelectedModulePathClick(Sender: TObject);
    procedure mniCopySelectedModuleNameClick(Sender: TObject);
    procedure mniCopySelectedModuleMemoryAddressClick(Sender: TObject);
    procedure mniCopyFileToClick(Sender: TObject);
    procedure mniKillProcessClick(Sender: TObject);
    procedure mniSaveToFileClick(Sender: TObject);
    procedure mniSelectedLineToSaveFileClick(Sender: TObject);
    procedure mniProcessDumpClick(Sender: TObject);
    procedure mniFileAttrClick(Sender: TObject);
    procedure mniOpenModuleFileAttiClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FSBLV1, FSBLV2: TFMScrollBar;
    procedure EnumProcess(lv: TListView);
    procedure EnumProcessModules(const intPID: Cardinal; lv: TListView);
    function GetFileVersion(const strExeName: string): String;
    procedure SaveModuleInfoToText(const strSaveFileName: String; const bSelected: Boolean = False);
    procedure SaveModuleInfoToExcel(const strSaveFileName: String; const bSelected: Boolean = False);
  public
    { Public declarations }
  end;

procedure db_ShowDllForm_Plugins(var frm: TFormClass; var strParentModuleName, strSubModuleName: PAnsiChar); stdcall;

implementation

{$R *.dfm}

procedure db_ShowDllForm_Plugins(var frm: TFormClass; var strParentModuleName, strSubModuleName: PAnsiChar); stdcall;
begin
  frm                     := TfrmProcessManager;
  strParentModuleName     := '程序员工具';
  strSubModuleName        := 'PM进程管理器';
  Application.Handle      := GetMainFormApplication.Handle;
  Application.Icon.Handle := GetDllModuleIconHandle(String(strParentModuleName), string(strSubModuleName));
end;

{ 获取进程路径 }
function GetProcessName(dwProcessID: LongInt; bFullPath: Bool): String;
var
  pinfo: PROCESS_INFO;
begin
  GetProcessInfo(dwProcessID, pinfo);
  Result := String(pinfo.ImagePathName);
end;

function GetProcessCommandLine(dwProcessID: DWORD): String;
var
  pinfo: PROCESS_INFO;
begin
  GetProcessInfo(dwProcessID, pinfo);
  Result := String(pinfo.CommandLine);
end;

{ 是否是  X64 }
function GetbX64Process(const intPID: Integer): Boolean;
begin
  Result := Is64BitProcess(intPID);
end;

function GetFileDesc(const strExeName: string): String;
var
  n, Len     : DWORD;
  Buf        : PChar;
  Value      : Pointer;
  szName     : array [0 .. 255] of Char;
  Transstring: string;
  Translation: Cardinal;
begin
  Result := '';

  Len := GetFileVersionInfoSize(PChar(strExeName), n);
  if Len > 0 then
  begin
    Buf := AllocMem(Len);
    if GetFileVersionInfo(PChar(strExeName), n, Len, Buf) then
    begin
      VerQueryValue(Buf, '\\VarFileInfo\\Translation', Value, Len);
      if (Len > 0) then
      begin
        Translation := Cardinal(Value^);
        Transstring := Format('%4.4x%4.4x', [(Translation and $0000FFFF), ((Translation shr 16) and $0000FFFF)]);
      end;
      StrPCopy(szName, 'StringFileInfo\' + Transstring + '\FileDescription');
      if VerQueryValue(Buf, szName, Value, Len) then
        Result := StrPas(PChar(Value));
    end;
    FreeMem(Buf, n);
  end;
end;

function GetFileCompany(const strExeName: string): String;
var
  n, Len     : DWORD;
  Buf        : PChar;
  Value      : Pointer;
  szName     : array [0 .. 255] of Char;
  Transstring: string;
  Translation: Cardinal;
begin
  Result := '';

  Len := GetFileVersionInfoSize(PChar(strExeName), n);
  if Len > 0 then
  begin
    Buf := AllocMem(Len);
    if GetFileVersionInfo(PChar(strExeName), n, Len, Buf) then
    begin
      VerQueryValue(Buf, '\\VarFileInfo\\Translation', Value, Len);
      if (Len > 0) then
      begin
        Translation := Cardinal(Value^);
        Transstring := Format('%4.4x%4.4x', [(Translation and $0000FFFF), ((Translation shr 16) and $0000FFFF)]);
      end;
      StrPCopy(szName, 'StringFileInfo\' + Transstring + '\CompanyName');
      if VerQueryValue(Buf, szName, Value, Len) then
        Result := StrPas(PChar(Value));
    end;
    FreeMem(Buf, n);
  end;
end;

procedure TfrmProcessManager.EnumProcess(lv: TListView);
var
  hSnap         : THANDLE;
  pe32          : TProcessEntry32;
  bFind         : Boolean;
  intCount      : Integer;
  strProcessName: String;
begin
  hSnap := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  if hSnap = INVALID_HANDLE_VALUE then
    Exit;

  try
    pe32.dwSize := SizeOf(TProcessEntry32);
    bFind       := Process32First(hSnap, pe32);
    if not bFind then
      Exit;

    intCount := 0;

    lv.Items.BeginUpdate;
    while bFind do
    begin
      Inc(intCount);
      with lv.Items.Add do
      begin
        Caption        := Format('%0.3d', [intCount]);
        strProcessName := GetProcessName(pe32.th32ProcessID, True);
        SubItems.Add(pe32.szExeFile);
        SubItems.Add(Format('%4d', [pe32.th32ProcessID]));
        SubItems.Add(IfThen(GetbX64Process(pe32.th32ProcessID), 'x64', 'x86'));
        SubItems.Add(strProcessName);
        SubItems.Add(GetFileDesc(strProcessName));
        SubItems.Add(GetFileCompany(strProcessName));
      end;
      bFind := Process32Next(hSnap, pe32);
    end;
    lv.Items.EndUpdate;
  finally
    CloseHandle(hSnap);
  end;
end;

function TfrmProcessManager.GetFileVersion(const strExeName: string): String;
var
  n, Len     : DWORD;
  Buf        : PChar;
  Value      : Pointer;
  szName     : array [0 .. 255] of Char;
  Transstring: string;
  Translation: Cardinal;
begin
  Result := '';

  Len := GetFileVersionInfoSize(PChar(strExeName), n);
  if Len > 0 then
  begin
    Buf := AllocMem(Len);
    if GetFileVersionInfo(PChar(strExeName), n, Len, Buf) then
    begin
      VerQueryValue(Buf, '\\VarFileInfo\\Translation', Value, Len);
      if (Len > 0) then
      begin
        Translation := Cardinal(Value^);
        Transstring := Format('%4.4x%4.4x', [(Translation and $0000FFFF), ((Translation shr 16) and $0000FFFF)]);
      end;
      StrPCopy(szName, 'StringFileInfo\' + Transstring + '\ProductVersion');
      if VerQueryValue(Buf, szName, Value, Len) then
        Result := StrPas(PChar(Value));
    end;
    FreeMem(Buf, n);
  end;
end;

procedure TfrmProcessManager.EnumProcessModules(const intPID: Cardinal; lv: TListView);
var
  intCount: Integer;
  pinfo   : PROCESS_INFO;
  I       : Integer;
begin
  lv.Clear;

  if intPID = 0 then
    Exit;

  GetProcessInfo(intPID, pinfo);
  intCount := pinfo.ModulesList.Length;
  for I    := 1 to intCount - 1 do
  begin
    with lv.Items.Add do
    begin
      Caption := Format('%0.3d', [I]);
      SubItems.Add(string(pinfo.ModulesList.Modules[I].ModuleName));
      SubItems.Add(string(pinfo.ModulesList.Modules[I].FullPath));
      SubItems.Add(Format('$%0.16x', [pinfo.ModulesList.Modules[I].BaseAddress]));
      SubItems.Add(Format('$%0.16x', [pinfo.ModulesList.Modules[I].EntryAddress]));
      SubItems.Add(Format('$%0.8x', [pinfo.ModulesList.Modules[I].SizeOfImage]));
      SubItems.Add(GetFileVersion(string(pinfo.ModulesList.Modules[I].FullPath)));
      SubItems.Add(GetFileCompany(string(pinfo.ModulesList.Modules[I].FullPath)));
    end;
  end;
end;

procedure TfrmProcessManager.FormActivate(Sender: TObject);
begin
  FSBLV1 := TFMScrollBar.Create(nil);
  FSBLV1.InitScrollbar(lvProcess);
  FSBLV2 := TFMScrollBar.Create(nil);
  FSBLV2.InitScrollbar(lvModule);
end;

procedure TfrmProcessManager.FormCreate(Sender: TObject);
begin
  EnumProcess(lvProcess);
end;

procedure TfrmProcessManager.FormDestroy(Sender: TObject);
begin
  FSBLV1.Free;
  FSBLV2.Free;
end;

procedure TfrmProcessManager.FormResize(Sender: TObject);
begin
  lvProcess.Column[4].Width := Width - 830;
  lvModule.Column[2].Width  := Width - 885;
end;

procedure TfrmProcessManager.lvProcessClick(Sender: TObject);
var
  intPID: Cardinal;
begin
  if lvProcess.Selected = nil then
    Exit;

  intPID := System.SysUtils.StrToInt(lvProcess.Selected.SubItems[1]);
  EnumProcessModules(intPID, lvModule);

  edtParam.Text := GetProcessCommandLine(intPID);
end;

var
  m_bSort: Boolean = False;

function CustomSortProc(Item1, Item2: TListItem; ParamSort: Integer): Integer; stdcall;
var
  txt1, txt2: string;
  intTemp1  : Integer;
  intTemp2  : Integer;
begin
  Result := 0;

  if ParamSort <> 0 then
  begin
    try
      txt1 := Item1.SubItems.Strings[ParamSort - 1];
      txt2 := Item2.SubItems.Strings[ParamSort - 1];
      if TryStrToInt(txt1, intTemp1) and TryStrToInt(txt2, intTemp2) then
      begin
        Result := IfThen(intTemp1 > intTemp2, 1 - Integer(m_bSort), Integer(m_bSort));
      end
      else
      begin
        Result := IfThen(m_bSort, 1, -1) * CompareText(txt1, txt2);
      end;
    except
    end;
  end
  else
  begin
    Result := IfThen(m_bSort, 1, -1) * CompareText(Item1.Caption, Item2.Caption);
  end;
end;

procedure TfrmProcessManager.lvProcessColumnClick(Sender: TObject; Column: TListColumn);
begin
  TListView(Sender).CustomSort(@CustomSortProc, Column.Index);
  m_bSort := not m_bSort;
end;

function SHOpenFolderAndSelectItems(pidlFolder: pItemIDList; cidl: Cardinal; apidl: Pointer; dwFlags: DWORD): HRESULT; stdcall; external shell32;

function OpenFolderAndSelectFile(const strFileName: string; const bEditMode: Boolean = False): Boolean;
var
  IIDL      : pItemIDList;
  pShellLink: IShellLink;
  hr        : Integer;
begin
  Result := False;

  hr := CoCreateInstance(CLSID_ShellLink, nil, CLSCTX_INPROC_SERVER, IID_IShellLink, &pShellLink);
  if hr = S_OK then
  begin
    pShellLink.SetPath(PChar(strFileName));
    pShellLink.GetIDList(&IIDL);
    Result := SHOpenFolderAndSelectItems(IIDL, 0, nil, Cardinal(bEditMode)) = S_OK;
  end;
end;

function FindMainFormHandle: THANDLE;
var
  strTitle      : string;
  strBuffer     : array [0 .. 255] of Char;
  strIniFileName: String;
begin
  GetModuleFileName(0, strBuffer, 256);
  strIniFileName := strBuffer;
  strIniFileName := ChangeFileExt(strIniFileName, '.ini');
  with TIniFile.Create(string(strIniFileName)) do
  begin
    strTitle := ReadString('UI', 'Title', '程序员工具箱 v2.0');
    Free;
  end;
  Result := FindWindow('TfrmMain', PChar(strTitle));
end;

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

procedure TfrmProcessManager.mniCopySelectedModulePathClick(Sender: TObject);
var
  I       : Integer;
  strValue: string;
begin
  if lvModule.SelCount = 0 then
    Exit;

  strValue := '';
  for I    := 0 to lvModule.Items.Count - 1 do
  begin
    if lvModule.Items[I].Selected then
    begin
      strValue := strValue + Chr(13) + Chr(10) + lvModule.Items[I].SubItems[1];
    end;
  end;
  Clipboard.AsText := Trim(strValue);
end;

procedure TfrmProcessManager.mniCopySelectedModuleNameClick(Sender: TObject);
var
  I       : Integer;
  strValue: string;
begin
  if lvModule.SelCount = 0 then
    Exit;

  strValue := '';
  for I    := 0 to lvModule.Items.Count - 1 do
  begin
    if lvModule.Items[I].Selected then
    begin
      strValue := strValue + Chr(13) + Chr(10) + lvModule.Items[I].SubItems[0];
    end;
  end;
  Clipboard.AsText := Trim(strValue);
end;

procedure TfrmProcessManager.mniCopySelectedModuleMemoryAddressClick(Sender: TObject);
var
  I       : Integer;
  strValue: string;
begin
  if lvModule.SelCount = 0 then
    Exit;

  strValue := '';
  for I    := 0 to lvModule.Items.Count - 1 do
  begin
    if lvModule.Items[I].Selected then
    begin
      strValue := strValue + Chr(13) + Chr(10) + lvModule.Items[I].SubItems[3];
    end;
  end;
  Clipboard.AsText := Trim(strValue);
end;

procedure TfrmProcessManager.mniEjectFromProcessClick(Sender: TObject);
var
  PID: Cardinal;
begin
  if lvModule.SelCount = 0 then
    Exit;

  if Trim(lvModule.Selected.SubItems[1]) = '' then
    Exit;

  if lvProcess.Selected = nil then
    Exit;

  if Trim(lvProcess.Selected.SubItems[1]) = '' then
    Exit;

  PID := System.SysUtils.StrToInt(lvProcess.Selected.SubItems[1]);
  EjectFromProcess(lvModule.Selected.SubItems[1], PID);
end;

function ShowFileProperties(FileName: String; Wnd: hWnd): Boolean;
var
  sfi: TSHELLEXECUTEINFOW;
begin
  with sfi do
  begin
    cbSize       := SizeOf(sfi);
    lpFile       := PChar(FileName);
    Wnd          := Wnd;
    fMask        := SEE_MASK_NOCLOSEPROCESS or SEE_MASK_INVOKEIDLIST or SEE_MASK_FLAG_NO_UI;
    lpVerb       := PChar('properties');
    lpIDList     := nil;
    lpDirectory  := nil;
    nShow        := 0;
    hInstApp     := 0;
    lpParameters := nil;
    dwHotKey     := 0;
    hIcon        := 0;
    hkeyClass    := 0;
    hProcess     := 0;
    lpClass      := nil;
  end;
  Result := ShellExecuteEX(@sfi);
end;

procedure TfrmProcessManager.mniFileAttrClick(Sender: TObject);
begin
  if lvProcess.Selected = nil then
    Exit;

  if Trim(lvProcess.Selected.SubItems[3]) = '' then
    Exit;

  ShowFileProperties(lvProcess.Selected.SubItems[3], 0);
end;

procedure TfrmProcessManager.mniDumpToDiskFileClick(Sender: TObject);
var
  msEXE    : TMemoryStream;
  PID      : Cardinal;
  hProcess : THANDLE;
  intLen   : Cardinal;
  hModAddr : UInt64;
  BytesRead: Winapi.Windows.SIZE_T;
begin
  if lvProcess.Selected = nil then
    Exit;

  if lvModule.ItemIndex = -1 then
    Exit;

  if Trim(lvProcess.Selected.SubItems[3]) = '' then
    Exit;

  dlgSaveEXE.FileName := lvModule.Items[lvModule.ItemIndex].SubItems[0];
  if not dlgSaveEXE.Execute then
    Exit;

  PID      := System.SysUtils.StrToInt(lvProcess.Selected.SubItems[1]);
  hProcess := OpenProcess(PROCESS_ALL_ACCESS, False, PID);
  if hProcess = INVALID_HANDLE_VALUE then
    Exit;

  hModAddr := StrToIntDef(lvModule.Items[lvModule.ItemIndex].SubItems[2], 0);
  intLen   := StrToIntDef(lvModule.Items[lvModule.ItemIndex].SubItems[4], 0);
  msEXE    := TMemoryStream.Create;
  try
    BytesRead  := 0;
    msEXE.Size := intLen;
    if ReadProcessMemory(hProcess, Pointer(hModAddr), msEXE.Memory, intLen, BytesRead) then
      msEXE.SaveToFile(dlgSaveEXE.FileName)
    else
      MessageBox(Handle, 'X86 无法读取 X64 内存，请使用 X64 版本', c_strMsgTitle, MB_OK or MB_ICONINFORMATION);
  finally
    msEXE.Free;
    CloseHandle(hProcess);
  end;
end;

procedure TfrmProcessManager.mniKillProcessClick(Sender: TObject);
var
  hProcess: THANDLE;
  PID     : Cardinal;
begin
  if lvProcess.Selected = nil then
    Exit;

  if Trim(lvProcess.Selected.SubItems[1]) = '' then
    Exit;

  PID      := System.SysUtils.StrToInt(lvProcess.Selected.SubItems[1]);
  hProcess := OpenProcess(PROCESS_TERMINATE, False, PID);
  if hProcess <> INVALID_HANDLE_VALUE then
  begin
    if TerminateProcess(hProcess, 0) then
    begin
      lvProcess.DeleteSelected;
    end;
    CloseHandle(hProcess);
  end;
end;

procedure TfrmProcessManager.mniDeleteProcessFileClick(Sender: TObject);
var
  hProcess   : THANDLE;
  PID        : Cardinal;
  strFileName: String;
begin
  if lvProcess.Selected = nil then
    Exit;

  if Trim(lvProcess.Selected.SubItems[1]) = '' then
    Exit;

  PID         := System.SysUtils.StrToInt(lvProcess.Selected.SubItems[1]);
  strFileName := lvProcess.Selected.SubItems[3];
  hProcess    := OpenProcess(PROCESS_TERMINATE, False, PID);
  if hProcess <> INVALID_HANDLE_VALUE then
  begin
    if TerminateProcess(hProcess, 0) then
    begin
      DeleteFile(strFileName);
      lvProcess.DeleteSelected;
    end;
    CloseHandle(hProcess);
  end;
end;

{ 进程注入 }
procedure TfrmProcessManager.mniDllInsertProcessClick(Sender: TObject);
var
  PID: Cardinal;
begin
  if lvProcess.Selected = nil then
    Exit;

  if Trim(lvProcess.Selected.SubItems[1]) = '' then
    Exit;

  if not dlgOpenDll.Execute then
    Exit;

  PID := System.SysUtils.StrToInt(lvProcess.Selected.SubItems[1]);
  InjectToProcess(dlgOpenDll.FileName, PID);
end;

procedure TfrmProcessManager.mniLoadPEClick(Sender: TObject);
begin
  //
end;

procedure TfrmProcessManager.mniOpenModuleFileAttiClick(Sender: TObject);
begin
  if lvModule.Selected = nil then
    Exit;

  if Trim(lvModule.Selected.SubItems[1]) = '' then
    Exit;

  ShowFileProperties(lvModule.Selected.SubItems[1], 0);
end;

procedure TfrmProcessManager.mniOpenModulePathClick(Sender: TObject);
begin
  if lvModule.Selected = nil then
    Exit;

  if Trim(lvModule.Selected.SubItems[1]) = '' then
    Exit;

  OpenFolderAndSelectFile(lvModule.Selected.SubItems[1]);
end;

procedure TfrmProcessManager.mniOpenProcessPathClick(Sender: TObject);
begin
  if lvProcess.Selected = nil then
    Exit;

  if Trim(lvProcess.Selected.SubItems[3]) = '' then
    Exit;

  OpenFolderAndSelectFile(lvProcess.Selected.SubItems[3]);
end;

procedure TfrmProcessManager.mniProcessDumpClick(Sender: TObject);
var
  msEXE    : TMemoryStream;
  PID      : Cardinal;
  hProcess : THANDLE;
  intLen   : Cardinal;
  hModAddr : UInt64;
  BytesRead: Winapi.Windows.SIZE_T;
  pinfo    : PROCESS_INFO;
begin
  if lvProcess.Selected = nil then
    Exit;

  if Trim(lvProcess.Selected.SubItems[3]) = '' then
    Exit;

  if not dlgSaveEXE.Execute then
    Exit;

  PID      := System.SysUtils.StrToInt(lvProcess.Selected.SubItems[1]);
  hProcess := OpenProcess(PROCESS_ALL_ACCESS, False, PID);
  if hProcess = INVALID_HANDLE_VALUE then
    Exit;

  GetProcessInfo(PID, pinfo);
  hModAddr := pinfo.ModulesList.Modules[0].BaseAddress;
  intLen   := pinfo.ModulesList.Modules[0].SizeOfImage;
  msEXE    := TMemoryStream.Create;
  try
    BytesRead  := 0;
    msEXE.Size := intLen;
    if ReadProcessMemory(hProcess, Pointer(hModAddr), msEXE.Memory, intLen, BytesRead) then
      msEXE.SaveToFile(dlgSaveEXE.FileName)
    else
      MessageBox(Handle, 'X86 无法读取 X64 内存，请使用 X64 版本', c_strMsgTitle, MB_OK or MB_ICONINFORMATION);
  finally
    msEXE.Free;
    CloseHandle(hProcess);
  end;
end;

procedure TfrmProcessManager.mniRenameProcessNameClick(Sender: TObject);
begin
  if lvProcess.Selected = nil then
    Exit;

  if Trim(lvProcess.Selected.SubItems[3]) = '' then
    Exit;

  OpenFolderAndSelectFile(lvProcess.Selected.SubItems[3], True);
end;

procedure TfrmProcessManager.mniCopyFileToClick(Sender: TObject);
var
  III        : Integer;
  strFileName: String;
  strSavePath: String;
begin
  if lvModule.SelCount = 0 then
    Exit;

  if not SelectDirectory('选择一个文件夹：', '', strSavePath, [], GetInstanceFromhWnd(FindMainFormHandle)) then
    Exit;

  for III := 0 to lvModule.Items.Count - 1 do
  begin
    if lvModule.Items.Item[III].Selected then
    begin
      strFileName := lvModule.Items.Item[III].SubItems[1];
      CopyFile(PChar(strFileName), PChar(strSavePath + '\' + ExtractFileName(strFileName)), True);
    end;
  end;
end;

procedure TfrmProcessManager.SaveModuleInfoToText(const strSaveFileName: String; const bSelected: Boolean = False);
var
  I        : Integer;
  strValue : string;
  lstModule: TStringList;

  procedure AddToList;
  var
    J       : Integer;
    strValue: string;
  begin
    strValue := lvModule.Items[I].Caption;
    for J    := 0 to lvModule.Columns.Count - 2 do
    begin
      strValue := strValue + Chr(9) + lvModule.Items[I].SubItems[J];
    end;
    lstModule.Add(strValue);
  end;

begin
  lstModule := TStringList.Create;
  try
    { 列名称 }
    strValue := lvModule.Columns[0].Caption;
    for I    := 1 to lvModule.Columns.Count - 1 do
    begin
      strValue := strValue + Chr(9) + lvModule.Columns[I].Caption;
    end;
    lstModule.Add(strValue);

    { 数据 }
    for I := 0 to lvModule.Items.Count - 1 do
    begin
      if bSelected and lvModule.Items[I].Selected then
        AddToList
      else
        AddToList;
    end;
    lstModule.SaveToFile(dlgSaveModuleInfo.FileName + '.txt');
  finally
    lstModule.Free;
  end;
end;

procedure TfrmProcessManager.SaveModuleInfoToExcel(const strSaveFileName: String; const bSelected: Boolean);
// var
// XLS : TXLSReadWriteII5;
// I, J: Integer;
// procedure AddToList;
// var
// I: Integer;
// begin
// for I := 0 to lvModule.Columns.Count - 1 do
// begin
// if I = 0 then
// XLS.Sheets[0].AsString[I + 1, J + 2] := lvModule.Items[J].Caption
// else
// XLS.Sheets[0].AsString[I + 1, J + 2] := lvModule.Items[J].SubItems[I - 1];
//
// XLS.Sheets[0].Cell[I + 1, J + 2].HorizAlignment := chaCenter;
// XLS.Sheets[0].Cell[I + 1, J + 2].VertAlignment  := cvaCenter;
// end;
// end;
//
begin
  // XLS := TXLSReadWriteII5.Create(nil);
  // try
  // XLS.FileName := strSaveFileName;
  //
  // for I := 1 to lvModule.Columns.Count do
  // begin
  // for J := 1 to lvModule.Items.Count + 1 do
  // begin
  // XLS.Sheets[0].Range.Items[I, J, I, J].BorderOutlineStyle := cbsThin;
  // XLS.Sheets[0].Range.Items[I, J, I, J].BorderOutlineColor := 0;
  // end;
  // end;
  //
  // for I := 1 to lvModule.Columns.Count do
  // begin
  // Application.ProcessMessages;
  // XLS.Sheets[0].AsString[I, 1]                  := lvModule.Column[I - 1].Caption;
  // XLS.Sheets[0].Columns[I].Width                := 6000;
  // XLS.Sheets[0].Cell[I, 1].FontColor            := clWhite;
  // XLS.Sheets[0].Cell[I, 1].FontStyle            := XLS.Sheets[0].Cell[I, 1].FontStyle + [xfsBold];
  // XLS.Sheets[0].Cell[I, 1].FillPatternForeColor := xcBlue;
  // XLS.Sheets[0].Cell[I, 1].HorizAlignment       := chaCenter;
  // XLS.Sheets[0].Cell[I, 1].VertAlignment        := cvaCenter;
  // end;
  //
  // for J := 0 to lvModule.Items.Count - 1 do
  // begin
  // if bSelected and lvModule.Items[J].Selected then
  // AddToList
  // else
  // AddToList;
  // end;
  //
  // XLS.Write;
  // finally
  // XLS.Free;
  // end;
end;

procedure TfrmProcessManager.mniSaveToFileClick(Sender: TObject);
begin
  if not dlgSaveModuleInfo.Execute then
    Exit;

  if dlgSaveModuleInfo.FilterIndex = 1 then
    SaveModuleInfoToText(dlgSaveModuleInfo.FileName + '.txt')
  else
    SaveModuleInfoToExcel(dlgSaveModuleInfo.FileName + '.xlsx');
end;

procedure TfrmProcessManager.mniSelectedLineToSaveFileClick(Sender: TObject);
begin
  if lvModule.SelCount = 0 then
    Exit;

  if not dlgSaveModuleInfo.Execute then
    Exit;

  if dlgSaveModuleInfo.FilterIndex = 1 then
    SaveModuleInfoToText(dlgSaveModuleInfo.FileName + '.txt', True)
  else
    SaveModuleInfoToExcel(dlgSaveModuleInfo.FileName + '.xlsx', True);
end;

end.
