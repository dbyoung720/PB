unit uBaseForm;
{
  Func : PBox Base Form Create Base UI
  Auth : dbyoung@sina.com
  Time : 2023-02-05
}

interface

uses
  Winapi.Windows, Winapi.Messages, System.Win.Registry, Winapi.IpRtrMib, Winapi.IpTypes, Winapi.IpHlpApi, Winapi.ShellAPI,
  System.Classes, System.SysUtils, System.StrUtils, System.IniFiles, System.UITypes, System.Math, System.Types, System.IOUtils,
  Vcl.ComCtrls, Vcl.StdCtrls, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.ExtCtrls, Vcl.Menus, uImgListEx, unmgr;

type
  TBaseForm = class(TForm)
  private
    FbMaxForm     : Boolean;
    FbMouseDown   : Boolean;
    FptOld        : TPoint;
    FOldPos       : TPoint;
    FbtnConfig    : TImage;
    FbtnMin       : TImage;
    FbtnMax       : TImage;
    FbtnClose     : TImage;
    FpnlTop       : TPanel;
    FimgLogo      : TImage;
    FpnlBottom    : TPanel;
    FpnlTime      : TPanel;
    FLabelTime    : TLabel;
    FBevelTime    : TBevel;
    FTimerTime    : TTimer;
    FpnlIP        : TPanel;
    FBevelIP      : TBevel;
    FLabelIP      : TLabel;
    FpmAdapterList: TPopupMenu;
    FPnlLeftAll   : TPanel;
    FpnlWeb       : TPanel;
    FBevelWeb     : TBevel;
    FLabelWeb     : TLabel;
    Fpnllogin     : TPanel;
    FTrayMenu     : TPopupMenu;
    procedure pnlMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure pnlMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure pnlMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure pnlDBLClick(Sender: TObject);
    procedure FormMaxSize;
    procedure FormNormalSize;
    procedure DelayTime(const intTime: Cardinal);
    function IsMouseLButtonDown(): Boolean;
    procedure OnSysBtnMouseEnter(Sender: TObject);
    procedure OnSysBtnMouseLeave(Sender: TObject);
    procedure OnSysBtnMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure OnSysBtnCloseClick(Sender: TObject);
    procedure OnSysBtnMaxClick(Sender: TObject);
    procedure OnSysBtnMinClick(Sender: TObject);
    procedure OnSysBtnConfigClick(Sender: TObject);
    procedure OnTimeClick(Sender: TObject);
    procedure OnTimerTime(Sender: TObject);
    procedure OnIPClick(Sender: TObject);
    procedure OnIPMouseEnter(Sender: TObject);
    procedure OnAdapterDrawItem(Sender: TObject; ACanvas: TCanvas; ARect: TRect; Selected: Boolean);
    procedure OnAdapterIPClick(Sender: TObject);
    procedure CreateSubControl(pnl: TPanel);
    procedure CreateSystemButton;
  protected
    procedure WMSYSCOMMAND(var msg: TWMSYSCOMMAND); message WM_SYSCOMMAND;
  public
    FLabellogin: TLabel;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property TrayMenu: TPopupMenu read FTrayMenu write FTrayMenu;
    procedure LoadButtonBmp(btn: TImage; const strResName: String; const intIndex: Integer);
  end;

{$R *.res }

const
  c_strDllExportFuncName         = 'db_ShowDllForm_Plugins';
  c_intButtonWidth               = 30;
  c_intTimeTop                   = 6;
  c_intBetweenVerticalDistance   = 5;
  c_strTitle                     = 'PBox 基于 DLL 窗口的模块化开发平台 v5.0';
  c_strIniUISection              = 'UI';
  c_strIniModuleSection          = 'Module';
  c_strMsgTitle: PChar           = '系统提示：';
  c_intDelphiDllFormCloseTimerID = $100000;
  c_intVCMFCDllFormCreateTimerID = $200000;
  c_intVCMFCDllFormCloseTimerID  = $300000;
  c_intVCMFCDllFormEndTimerID    = $400000;
  c_intVCDLGDllFormEndTimerID    = $500000;
  c_intEXEFormCreateTimerID      = $600000;
  c_intEXEFormCloseTimerID       = $700000;

type
  { 界面风格 }
  TUIType = (uiMenu, uiButton, uiList, uiCenter);

  TCallFunc = procedure(const bExit: Boolean = False) of object;

  { DLL 类型：Delphi Dll、VC Dialog Dll、VC MFC Dll、QT Dll、EXE }
  TLangStyle = (lsDelphiDll, lsVCDLGDll, lsVCMFCDll, lsQTDll, lsEXE);

  { DLL 导出函数定义 }
  Tdb_ShowDllForm_Plugins_Delphi = procedure(var frm: TFormClass; var strParentModuleName, strModuleName: PAnsiChar); stdcall;                                                                           // Delphi
  Tdb_ShowDllForm_Plugins_VCForm = procedure(var vct: TLangStyle; var strParentModuleName, strModuleName: PAnsiChar; var strClassName, strWindowName: PAnsiChar; const bShow: Boolean = False); stdcall; // VC
  Tdb_ShowDllForm_Plugins_QTForm = procedure(var vct: TLangStyle; var strParentModuleName, strModuleName: PAnsiChar; var strClassName, strWindowName: PAnsiChar; const bShow: Boolean = False); stdcall; // QT

  { 数据库登录密码回调函数 }
  TOnCheckPassword = function(const strPassword: PAnsiChar): PAnsiChar; stdcall;

var
  FstrUserLoginName: String = 'dbyoung';

procedure DLog(const strLog: String);

{ 只允许运行一个实例 }
procedure OnlyRunOneInstance;

{ 去除标题栏 }
procedure RemoveCaption(hWnd: THandle);

{ 搜索加载所有 DLL 模块 }
procedure LoadAllDLLPlugins(var lstDll: THashedStringList; var ilMainMenu: TImageList);

{ 搜索加载所有 EXE 模块 }
procedure LoadAllEXEPlugins(var lstDll: THashedStringList; var ilMainMenu: TImageList);

{ 延时函数 }
procedure DelayTime(const intTime: Cardinal);

{ 将 EXE 主窗体放置到 Tab Dll 窗口中 }
procedure SetParentForm(const hWnd: THandle; TabDll: TTabSheet; const intPID: Integer);

{ 删除插件配置文件中关于窗体位置的配置信息 }
procedure CheckPlugInConfigSize;

{ 检查 Sysinternals 软件许可 }
procedure CheckSysinternalsAllow(const strEXEFileName: String);

{ 获取当前显示风格 }
function GetCurrUIStyle: TUIType;

{ 程序关闭后，回到默认的 Tab 页 }
procedure RestoreDefultTabSheet(pgAll: TPageControl);

{ 对齐字符串；即固定长度 }
function AlignStringWidth(const strValue: string; const Font: TFont; const intMaxLen: Integer = 200): String;

{ 获取控件高度 }
function GetLabelHeight(const strFontName: string; const intFontSize: Integer): Integer;

{ 获取垂直位置最大间隔 }
function GetMaxInstance(mmMain: TMainMenu): Integer;

{ 加速加载配置文件名称 }
function GetLoadSpeedFileName_Config: String;

{ 加速加载图标文件名称 }
function GetLoadSpeedFileName_icolst: String;

{ 是否开启了加速加载子模块 }
function CheckLoadSpeed: Boolean;

{ 加速加载时，每个菜单项的图标 }
procedure LoadAllMenuIconSpeed(const ilMainMenu: TImageList);

{ 排序模块 }
procedure SortModuleList(var lstDll: THashedStringList);

{ 显示登录窗体 }
function ShowLoginForm(OnCheckPassword: TOnCheckPassword): String;

{ 从 .msc 文件中获取图标 }
procedure LoadIconFromMSCFile(const strMSCFileName: string; var IcoMSC: TIcon);

implementation

procedure DLog(const strLog: String);
begin
  OutputDebugString(PChar(Format('%s  %s', [FormatDateTime('yyyy-MM-dd hh:mm:ss', Now), strLog])));
end;

{ 只允许运行一个实例 }
procedure OnlyRunOneInstance;
var
  hMainForm       : THandle;
  strTitle        : String;
  bOnlyOneInstance: Boolean;
begin
  with TIniFile.Create(ChangeFileExt(ParamStr(0), '.ini')) do
  begin
    strTitle         := ReadString(c_strIniUISection, 'Title', c_strTitle);
    bOnlyOneInstance := ReadBool(c_strIniUISection, 'OnlyOneInstance', True);
    Free;
  end;

  if not bOnlyOneInstance then
    Exit;

  hMainForm := FindWindow('TfrmPBox', PChar(strTitle));
  if hMainForm <> 0 then
  begin
    MessageBox(0, '程序已经运行，无需重复运行', '系统提示：', MB_OK OR MB_ICONERROR);
    if IsIconic(hMainForm) then
      PostMessage(hMainForm, WM_SYSCOMMAND, SC_RESTORE, 0);
    BringWindowToTop(hMainForm);
    SetForegroundWindow(hMainForm);
    Halt;
    Exit;
  end;
end;

{ 加速加载配置文件名称 }
function GetLoadSpeedFileName_Config: String;
begin
  Result := ExtractFilePath(ParamStr(0)) + 'plugins\' + ChangeFileExt(ExtractFileName(ParamStr(0)), '.lsc');
end;

{ 加速加载图标文件名称 }
function GetLoadSpeedFileName_icolst: String;
begin
  Result := ExtractFilePath(ParamStr(0)) + 'plugins\' + ChangeFileExt(ExtractFileName(ParamStr(0)), '.lsi');
end;

{ 是否开启了加速加载子模块 }
function CheckLoadSpeed: Boolean;
begin
  with TIniFile.Create(ChangeFileExt(ParamStr(0), '.ini')) do
  begin
    Result := ReadBool(c_strIniUISection, 'LoadSpeed', False) and FileExists(GetLoadSpeedFileName_Config) and FileExists(GetLoadSpeedFileName_icolst);
    Free;
  end;
end;

{ 加速加载时，每个菜单项的图标 }
procedure LoadAllMenuIconSpeed(const ilMainMenu: TImageList);
begin
  TImageListEx(ilMainMenu).LoadFromFile(GetLoadSpeedFileName_icolst);
end;

{ 获取控件高度 }
function GetLabelHeight(const strFontName: string; const intFontSize: Integer): Integer;
const
  c_strName = '记事本';
var
  DC      : HDC;
  Font    : TFont;
  hSavFont: HFont;
  Size    : TSize;
begin
  DC   := GetDC(0);
  Font := TFont.Create;
  try
    Font.Name := strFontName;
    Font.Size := intFontSize;
    hSavFont  := SelectObject(DC, Font.Handle);
    GetTextExtentPoint32(DC, PChar(c_strName), Length(c_strName), Size);
    SelectObject(DC, hSavFont);
    Result := Size.cy;
  finally
    ReleaseDC(0, DC);
    Font.Free;
  end;
end;

{ 获取垂直位置最大间隔 }
function GetMaxInstance(mmMain: TMainMenu): Integer;
var
  intMax               : Integer;
  arrInt               : array of Integer;
  I                    : Integer;
  intLabelPModuleHeight: Integer;
  intLabelSModuleHeight: Integer;
begin
  { 取最多行的模块个数 }
  SetLength(arrInt, mmMain.Items.Count);
  for I := 0 to mmMain.Items.Count - 1 do
  begin
    arrInt[I] := mmMain.Items.Items[I].Count;
  end;
  intMax := MaxIntValue(arrInt);

  intLabelPModuleHeight := GetLabelHeight('宋体', 17);
  intLabelSModuleHeight := GetLabelHeight('宋体', 12);

  Result := (intLabelSModuleHeight + c_intBetweenVerticalDistance * 2) * (Ifthen(intMax mod 3 = 0, 0, 1) + intMax div 3) + intLabelPModuleHeight;
end;

{ 获取字符串宽度；包含中英文、数字等 }
function GetStringWidth(const strValue: string; const Font: TFont): Integer;
var
  DC      : HDC;
  hSavFont: HFont;
  Size    : TSize;
begin
  DC       := GetDC(0);
  hSavFont := SelectObject(DC, Font.Handle);
  GetTextExtentPoint32(DC, PChar(strValue), Length(strValue), Size);
  SelectObject(DC, hSavFont);
  ReleaseDC(0, DC);
  Result := Size.cx;
end;

{ 对齐字符串；即固定长度 }
function AlignStringWidth(const strValue: string; const Font: TFont; const intMaxLen: Integer = 200): String;
var
  intLen: Integer;
begin
  Result := strValue;
  intLen := GetStringWidth(strValue, Font);
  if intLen >= intMaxLen then
    Exit;

  while True do
  begin
    Result := Result + ' ';
    if GetStringWidth(Result, Font) >= intMaxLen then
      Break;
  end;
end;

{ 程序关闭后，回到默认的 Tab 页 }
procedure RestoreDefultTabSheet(pgAll: TPageControl);
begin
  pgAll.ActivePageIndex := Integer(GetCurrUIStyle);
end;

{ 获取当前显示风格 }
function GetCurrUIStyle: TUIType;
begin
  with TIniFile.Create(ChangeFileExt(ParamStr(0), '.ini')) do
  begin
    Result := TUIType(ReadInteger(c_strIniUISection, 'ShowStyle', 0));
    Free;
  end;
end;

{ 删除插件配置文件中关于窗体位置的配置信息 }
procedure CheckPlugInConfigSize;
var
  strPlugInsPath: String;
  lstFiles      : TStringDynArray;
  strFileNameCFG: string;
begin
  strPlugInsPath := ExtractFilePath(ParamStr(0)) + 'plugins';
  if not DirectoryExists(strPlugInsPath) then
    Exit;

  lstFiles := TDirectory.GetFiles(strPlugInsPath, '*.cfg', TSearchOption.soAllDirectories);
  for strFileNameCFG in lstFiles do
  begin
    with TIniFile.Create(strFileNameCFG) do
    begin
      DeleteKey('General', 'WinPos');
      Free;
    end;
  end;
end;

procedure CheckSysinternalsREG(const strProgramName: String);
begin
  with TRegistry.Create do
  begin
    RootKey := HKEY_CURRENT_USER;
    if not OpenKey('Software\Sysinternals\' + strProgramName, False) then
    begin
      OpenKey('Software\Sysinternals\' + strProgramName, True);
      WriteInteger('EulaAccepted', 1);
    end;
    Free;
  end;
end;

{ 检查 Sysinternals 软件许可 }
procedure CheckSysinternalsAllow(const strEXEFileName: String);
const
  c_strSysinternalsSoft: array [0 .. 6] of string = ('AutoRuns.exe', 'AutoRuns64.exe', 'DbgView.exe', 'procexp.exe', 'procexp64.exe', 'Procmon.exe', 'Procmon64.exe');
var
  strFileName: String;
begin
  strFileName := ExtractFileName(strEXEFileName);
  if (SameText(strFileName, c_strSysinternalsSoft[0])) or (SameText(strFileName, c_strSysinternalsSoft[1])) then
    CheckSysinternalsREG('AutoRuns')
  else if SameText(strFileName, c_strSysinternalsSoft[2]) then
    CheckSysinternalsREG('DbgView')
  else if (SameText(strFileName, c_strSysinternalsSoft[3])) or (SameText(strFileName, c_strSysinternalsSoft[4])) then
    CheckSysinternalsREG('Process Explorer')
  else if (SameText(strFileName, c_strSysinternalsSoft[5])) or (SameText(strFileName, c_strSysinternalsSoft[6])) then
    CheckSysinternalsREG('Process Monitor');
end;

var
  FExeTabSheet: TTabSheet;

function EnumNewMainForm(hWnd: THandle; lParam1: LPARAM): Boolean; stdcall;
var
  intPID: DWORD;
  rct   : TRect;
begin
  GetWindowThreadProcessId(hWnd, intPID);
  if (Cardinal(lParam1) = intPID) and (GetParent(hWnd) = 0) then
  begin
    GetWindowRect(hWnd, rct);
    if (rct.width > 100) and (rct.Height > 100) and IsWindowVisible(hWnd) then
    begin
      KillTimer(Application.MainForm.Handle, $3000);
      SetParentForm(hWnd, FExeTabSheet, intPID);
    end;
  end;
  Result := True;
end;

{ 将 EXE 主窗体放置到 Tab Dll 窗口中 }
procedure SetParentForm(const hWnd: THandle; TabDll: TTabSheet; const intPID: Integer);
var
  intST, intET: Cardinal;
  bOK         : Boolean;
begin
  FExeTabSheet := TabDll;

  { 设置父窗体为 TabSheet }
  bOK := True;
  if Winapi.Windows.SetParent(hWnd, TabDll.Handle) = 0 then
  begin
    bOK   := False;
    intST := GetTickCount;
    while True do
    begin
      Application.ProcessMessages;
      intET := GetTickCount;
      if intET - intST >= 10 * 1000 then
        Break;

      if Winapi.Windows.SetParent(hWnd, TabDll.Handle) <> 0 then
      begin
        bOK := True;
        Break;
      end;
    end;
  end;

  if not bOK then
  begin
    EnumWindows(@EnumNewMainForm, intPID);
    Exit;
  end;

  { 最大化 Dll 子窗体 }
  bOK := True;
  if not SetWindowPos(hWnd, TabDll.Handle, 0, 0, TabDll.width, TabDll.Height, SWP_NOZORDER OR SWP_NOACTIVATE) then
  begin
    bOK   := False;
    intST := GetTickCount;
    while True do
    begin
      Application.ProcessMessages;
      intET := GetTickCount;
      if intET - intST >= 10 * 1000 then
        Break;

      if SetWindowPos(hWnd, TabDll.Handle, 0, 0, TabDll.width, TabDll.Height, SWP_NOZORDER OR SWP_NOACTIVATE) then
      begin
        bOK := True;
        Break;
      end;
    end;
  end;
  if not bOK then
  begin
    EnumWindows(@EnumNewMainForm, intPID);
    Exit;
  end;

  RemoveMenu(GetSystemMenu(hWnd, False), 0, MF_BYPOSITION); // 删除移动菜单
  RemoveMenu(GetSystemMenu(hWnd, False), 0, MF_BYPOSITION); // 删除移动菜单
  RemoveMenu(GetSystemMenu(hWnd, False), 0, MF_BYPOSITION); // 删除移动菜单
  RemoveMenu(GetSystemMenu(hWnd, False), 0, MF_BYPOSITION); // 删除移动菜单
  RemoveMenu(GetSystemMenu(hWnd, False), 0, MF_BYPOSITION); // 删除移动菜单
  RemoveMenu(GetSystemMenu(hWnd, False), 0, MF_BYPOSITION); // 删除移动菜单

  { 设置窗体风格 }
  bOK := True;
  if SetWindowLong(hWnd, GWL_STYLE, Integer(WS_CAPTION OR WS_POPUP OR WS_VISIBLE OR WS_CLIPSIBLINGS OR WS_CLIPCHILDREN OR WS_SYSMENU)) = 0 then
  begin
    bOK   := False;
    intST := GetTickCount;
    while True do
    begin
      Application.ProcessMessages;
      intET := GetTickCount;
      if intET - intST >= 10 * 1000 then
        Break;

      if SetWindowLong(hWnd, GWL_STYLE, Integer(WS_CAPTION OR WS_POPUP OR WS_VISIBLE OR WS_CLIPSIBLINGS OR WS_CLIPCHILDREN OR WS_SYSMENU)) <> 0 then
      begin
        bOK := True;
        Break;
      end;
    end;
  end;
  if not bOK then
  begin
    EnumWindows(@EnumNewMainForm, intPID);
    Exit;
  end;

  { 设置窗体扩展风格 }
  bOK := True;
  if SetWindowLong(hWnd, GWL_EXSTYLE, Integer(WS_EX_LEFT OR WS_EX_LTRREADING OR WS_EX_DLGMODALFRAME OR WS_EX_WINDOWEDGE OR WS_EX_CONTROLPARENT)) = 0 then // $00010000);                                                                              // $00010101
  begin
    bOK   := False;
    intST := GetTickCount;
    while True do
    begin
      Application.ProcessMessages;
      intET := GetTickCount;
      if intET - intST >= 10 * 1000 then
        Break;

      if SetWindowLong(hWnd, GWL_EXSTYLE, Integer(WS_EX_LEFT OR WS_EX_LTRREADING OR WS_EX_DLGMODALFRAME OR WS_EX_WINDOWEDGE OR WS_EX_CONTROLPARENT)) <> 0 then // $00010000);                                                                              // $00010101
      begin
        bOK := True;
        Break;
      end;
    end;
  end;
  if not bOK then
  begin
    EnumWindows(@EnumNewMainForm, intPID);
    Exit;
  end;

  { 去除标题栏 }
  RemoveCaption(hWnd);

  { 显示窗体 }
  bOK := True;
  if not ShowWindow(hWnd, SW_SHOWNORMAL) then
  begin
    bOK   := False;
    intST := GetTickCount;
    while True do
    begin
      Application.ProcessMessages;
      intET := GetTickCount;
      if intET - intST >= 10 * 1000 then
        Break;

      if ShowWindow(hWnd, SW_SHOWNORMAL) then
      begin
        bOK := True;
        Break;
      end;
    end;
  end;
  if not bOK then
  begin
    EnumWindows(@EnumNewMainForm, intPID);
    Exit;
  end;

  Application.MainForm.Height := Application.MainForm.Height + 1;
  Application.MainForm.Height := Application.MainForm.Height - 1;
end;

{ 延时函数 }
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

procedure FindTableFilePos(const sts: array of TImageSectionHeader; const intVA: Cardinal; var intRA: Cardinal);
var
  III, Count: Integer;
begin
  intRA := 0;

  Count   := Length(sts);
  for III := 0 to Count - 2 do
  begin
    if (intVA >= sts[III + 0].VirtualAddress) and (intVA < sts[III + 1].VirtualAddress) then
    begin
      intRA := (intVA - sts[III].VirtualAddress) + sts[III].PointerToRawData;
      Break;
    end;
  end;
end;

{ 是否包含指定导出函数 }
function CheckDllExportFunc(const strDllFileName, strDllExportFuncName: string): Boolean;
var
  fHandle    : Integer;
  peHead     : TImageDosHeader;
  intOffset  : Integer;
  peNTHead32 : TImageNtHeaders32;
  peNTHead64 : TImageNtHeaders64;
  sts        : TArray<TImageSectionHeader>;
  intVA      : Cardinal;
  intRA      : Cardinal;
  I, Count   : Integer;
  intLen     : Integer;
  eft        : TImageExportDirectory;
  intFuncRA  : Cardinal;
  chrFuncName: array [0 .. 255] of AnsiChar;
  strFuncName: String;
begin
  Result  := False;
  fHandle := FileOpen(strDllFileName, fmShareDenyNone or fmOpenRead);
  if fHandle <= 0 then
    Exit;

  try
    FileRead(fHandle, peHead, SizeOf(TImageDosHeader));
    if peHead.e_magic <> IMAGE_DOS_SIGNATURE then
      Exit;

    intOffset := peHead._lfanew;
    FileSeek(fHandle, intOffset, 0);
    FileRead(fHandle, peNTHead32, SizeOf(TImageNtHeaders));
    if peNTHead32.Signature <> IMAGE_NT_SIGNATURE then
      Exit;

    { 获取导出函数表 }
    if peNTHead32.FileHeader.Machine = IMAGE_FILE_MACHINE_AMD64 then
    begin
      { X64 Dll }
      FileSeek(fHandle, 0, 0);
      FileRead(fHandle, peHead, SizeOf(TImageDosHeader));
      intOffset := peHead._lfanew;
      FileSeek(fHandle, intOffset, 0);
      FileRead(fHandle, peNTHead64, SizeOf(TImageNtHeaders64));
      if peNTHead64.Signature <> IMAGE_NT_SIGNATURE then
        Exit;

      Count := peNTHead64.FileHeader.NumberOfSections;
      SetLength(sts, Count);
      intLen := Count * SizeOf(TImageSectionHeader);
      FileSeek(fHandle, intOffset + SizeOf(TImageNtHeaders64), 0);
      FileRead(fHandle, sts[0], intLen);
      intVA := peNTHead64.OptionalHeader.DataDirectory[0].VirtualAddress;
      if intVA = 0 then
        Exit;
    end
    else
    begin
      { X86 Dll }
      Count := peNTHead32.FileHeader.NumberOfSections;
      SetLength(sts, Count);
      intLen := Count * SizeOf(TImageSectionHeader);
      FileSeek(fHandle, intOffset + SizeOf(TImageNtHeaders32), 0);
      FileRead(fHandle, sts[0], intLen);
      intVA := peNTHead32.OptionalHeader.DataDirectory[0].VirtualAddress;
      if intVA = 0 then
        Exit;
    end;

    FindTableFilePos(sts, intVA, intRA);
    FileSeek(fHandle, intRA, 0);
    FileRead(fHandle, eft, SizeOf(TImageExportDirectory));
    if eft.NumberOfNames = 0 then
      Exit;

    { 导出函数 }
    for I := 0 to eft.NumberOfNames - 1 do
    begin
      FileSeek(fHandle, eft.AddressOfNames - intVA + intRA + DWORD(4 * I), 0);
      FileRead(fHandle, intFuncRA, 4);
      FileSeek(fHandle, intFuncRA - intVA + intRA, 0);
      FileRead(fHandle, chrFuncName, 256);
      strFuncName := string(chrFuncName);
      if SameText(strFuncName, strDllExportFuncName) then
      begin
        Result := True;
        Break;
      end;
    end;
  finally
    FileClose(fHandle);
  end;
end;

function GetSystemPath: String;
var
  Buffer: array [0 .. 255] of Char;
begin
  GetSystemDirectory(Buffer, 256);
  Result := Buffer;
end;

{ 从 .msc 文件中获取图标 }
procedure LoadIconFromMSCFile(const strMSCFileName: string; var IcoMSC: TIcon);
var
  strLine       : String;
  strSystemPath : String;
  I, J, intIndex: Integer;
  intIconIndex  : Integer;
  strDllFileName: String;
  strTemp       : String;
begin
  with TStringList.Create do
  begin
    intIndex      := -1;
    strSystemPath := GetSystemPath;
    LoadFromFile(strSystemPath + '\' + strMSCFileName, TEncoding.ASCII);

    for I := 0 to Count - 1 do
    begin
      strLine := Strings[I];
      if strLine <> '' then
      begin
        if Pos('<Icon Index="', strLine) > 0 then
        begin
          intIndex := I;
          Break;
        end;
      end;
    end;

    if intIndex <> -1 then
    begin
      strLine      := Strings[intIndex];
      I            := Pos('"', strLine);
      strTemp      := RightStr(strLine, Length(strLine) - I);
      J            := Pos('"', strTemp);
      intIconIndex := StrToIntDef(MidStr(strLine, I + 1, J - 1), 0);

      I              := Pos('File="', strLine);
      strTemp        := RightStr(strLine, Length(strLine) - I - 5);
      J              := Pos('"', strTemp);
      strDllFileName := MidStr(strTemp, 1, J - 1);

      IcoMSC.Handle := ExtractIcon(HInstance, PChar(strDllFileName), intIconIndex);
    end;

    Free;
  end;
end;

function GetDllFileIcon(const strPModuleName, strSModuleName: string; var ilMainMenu: TImageList): Integer;
var
  strIconFilePath: String;
  strIconFileName: String;
  IcoExe         : TIcon;
begin
  Result := -1;
  with TIniFile.Create(ChangeFileExt(ParamStr(0), '.ini')) do
  begin
    strIconFilePath := ReadString(c_strIniModuleSection, Format('%s_%s_ICON', [strPModuleName, strSModuleName]), '');
    strIconFileName := ExtractFilePath(ParamStr(0)) + 'Plugins\Icon\' + strIconFilePath;
    if FileExists(strIconFileName) then
    begin
      IcoExe := TIcon.Create;
      try
        IcoExe.LoadFromFile(strIconFileName);
        Result := ilMainMenu.AddIcon(IcoExe);
      finally
        IcoExe.Free;
      end;
    end;
    Free;
  end;
end;

function GetExeFileIcon(const strFileName: String; var ilMainMenu: TImageList): Integer;
var
  IcoExe: TIcon;
begin
  Result := -1;
  if CompareText(ExtractFileExt(strFileName), '.msc') = 0 then
  begin
    IcoExe := TIcon.Create;
    try
      { 从 .msc 文件中获取图标 }
      LoadIconFromMSCFile(strFileName, IcoExe);
      Result := ilMainMenu.AddIcon(IcoExe);
    finally
      IcoExe.Free;
    end;
  end
  else
  begin
    if ExtractIcon(HInstance, PChar(strFileName), $FFFFFFFF) > 0 then
    begin
      IcoExe := TIcon.Create;
      try
        IcoExe.Handle := ExtractIcon(HInstance, PChar(strFileName), 0);
        Result        := ilMainMenu.AddIcon(IcoExe);
      finally
        IcoExe.Free;
      end;
    end;
  end;
end;

{ 获取 Dll 参数，并添加到列表 }
procedure AddDllInfoToList(var lstDll: THashedStringList; var ilMainMenu: TImageList; const strDllFileName: string; pFunc: Pointer);
var
  strPModuleName : PAnsiChar;
  strSModuleName : PAnsiChar;
  strVCClassName : PAnsiChar;
  strVCWindowName: PAnsiChar;
  ltDll          : TLangStyle;
  frm            : TFormClass;
  intIconIndex   : Integer;
  strInfo        : string;
begin

  strPModuleName  := '';
  strSModuleName  := '';
  strVCClassName  := '';
  strVCWindowName := '';
  Tdb_ShowDllForm_Plugins_VCForm(pFunc)(ltDll, strPModuleName, strSModuleName, strVCClassName, strVCWindowName);
  if strVCClassName = '' then
  begin
    Tdb_ShowDllForm_Plugins_Delphi(pFunc)(frm, strPModuleName, strSModuleName);
    strVCClassName  := '';
    strVCWindowName := '';
    ltDll           := lsDelphiDll;
  end;
  intIconIndex := GetDllFileIcon(string(strPModuleName), string(strSModuleName), ilMainMenu);
  strInfo      := ExtractFileName(strDllFileName) + '=' + string(strPModuleName) + ';' + string(strSModuleName) + ';' + string(strVCClassName) + ';' + string(strVCWindowName) + ';' + IntToStr(intIconIndex) + ';' + IntToStr(Integer(ltDll));
  lstDll.Add(strInfo);
end;

{ 搜索加载所有 DLL 模块 }
procedure LoadAllDLLPlugins(var lstDll: THashedStringList; var ilMainMenu: TImageList);
var
  strPath  : String;
  lstFile  : TStringDynArray;
  sFileName: String;
  hDll     : HMODULE;
  pFunc    : Pointer;
begin
  if not DirectoryExists(ExtractFilePath(ParamStr(0)) + 'plugins') then
    Exit;

  strPath := ExtractFilePath(ParamStr(0)) + 'plugins';
  lstFile := TDirectory.GetFiles(strPath, '*.dll');
  if Length(lstFile) = 0 then
    Exit;

  lstDll.Clear;
  for sFileName in lstFile do
  begin
    { 是否包含指定导出函数 }
    if not CheckDllExportFunc(sFileName, c_strDllExportFuncName) then
      Continue;

    { 加载 Dll，获取参数 }
    hDll := LoadLibrary(PChar(sFileName));
    if hDll <= 0 then
      Continue;

    try
      pFunc := GetProcaddress(hDll, c_strDllExportFuncName);
      if not Assigned(pFunc) then
      begin
        FreeLibrary(hDll);
        Continue;
      end;

      { 获取 Dll 参数，添加到列表 }
      AddDllInfoToList(lstDll, ilMainMenu, sFileName, pFunc);
    finally
      FreeLibrary(hDll);
    end;
  end;
end;

{ 搜索加载所有 EXE 模块 }
procedure LoadAllEXEPlugins(var lstDll: THashedStringList; var ilMainMenu: TImageList);
var
  lstEXE      : TStringList;
  I, J        : Integer;
  strEXEInfo  : String;
  strFileName : String;
  intIconIndex: Integer;
begin
  with TIniFile.Create(ChangeFileExt(ParamStr(0), '.ini')) do
  begin
    lstEXE := TStringList.Create;
    try
      ReadSection('EXE', lstEXE);
      for I := 0 to lstEXE.Count - 1 do
      begin
        strFileName  := lstEXE.Strings[I];
        strEXEInfo   := ReadString('EXE', strFileName, '');
        intIconIndex := GetExeFileIcon(strFileName, ilMainMenu);
        J            := strEXEInfo.CountChar(';');
        if J = 4 then
          strEXEInfo := strEXEInfo + IntToStr(intIconIndex)
        else
          strEXEInfo := strEXEInfo + ';' + IntToStr(intIconIndex);
        strEXEInfo   := strEXEInfo + ';' + IntToStr(Integer(TLangStyle(lsEXE)));
        lstDll.Add(Format('%s=%s', [strFileName, strEXEInfo]));
      end;
    finally
      lstEXE.Free;
    end;
    Free;
  end;
end;

{ 去除标题栏 }
procedure RemoveCaption(hWnd: THandle);
var
  bShowCloseButton: Boolean;
begin
  with TIniFile.Create(ChangeFileExt(ParamStr(0), '.ini')) do
  begin
    bShowCloseButton := ReadBool(c_strIniUISection, 'ShowCloseButton', True);
    Free;
  end;

  if not bShowCloseButton then
    SetWindowLong(hWnd, GWL_STYLE, GetWindowLong(hWnd, GWL_STYLE) xor WS_CAPTION);
end;

{ 获取网络下载上传速度 }
var
  FintDnBytes: UInt64 = 0;
  FintUpBytes: UInt64 = 0;

procedure GetWebSpeed(var strDnSpeed, strUpSpeed: string);
var
  NetworkManager        : TNetworkManager;
  lsNetworkTraffic      : TList;
  I                     : Integer;
  intDnSpeed, intUpSpeed: Cardinal;
  strNetworkDesc        : String;
  intDnBytes            : UInt64;
  intUpBytes            : UInt64;
begin
  NetworkManager   := TNetworkManager.Create(0);
  lsNetworkTraffic := TList.Create;
  try
    NetworkManager.GetNetworkTraffic(lsNetworkTraffic);
    if lsNetworkTraffic.Count > 0 then
    begin
      intDnBytes := 0;
      intUpBytes := 0;

      for I := 0 to lsNetworkTraffic.Count - 1 do
      begin
        strNetworkDesc := NetworkManager.GetDescrString(PMibIfRow(lsNetworkTraffic.Items[I])^.bDescr);
        if Pos('-0000', strNetworkDesc) = 0 then
        begin
          intDnBytes := intDnBytes + PMibIfRow(lsNetworkTraffic.Items[I])^.dwInOctets;
          intUpBytes := intUpBytes + PMibIfRow(lsNetworkTraffic.Items[I])^.dwOutOctets;
        end;
      end;

      { 第一次 }
      if (FintDnBytes = 0) and (FintUpBytes = 0) then
      begin
        strDnSpeed := Format('%0.2f K/S', [0.0]);
        strUpSpeed := Format('%0.2f K/S', [0.0]);

        FintDnBytes := intDnBytes;
        FintUpBytes := intUpBytes;
        Exit;
      end;

      { 下载速度 }
      intDnSpeed := intDnBytes - FintDnBytes;
      if intDnSpeed > 1024 * 1024 then
        strDnSpeed := Format('%0.2f M/S', [intDnSpeed / 1024 / 1024])
      else
        strDnSpeed := Format('%0.2f K/S', [intDnSpeed / 1024]);

      { 上传速度 }
      intUpSpeed := intUpBytes - FintUpBytes;
      if intUpSpeed > 1024 * 1024 then
        strUpSpeed := Format('%0.2f M/S', [intUpSpeed / 1024 / 1024])
      else
        strUpSpeed := Format('%0.2f K/S', [intUpSpeed / 1024]);

      FintDnBytes := intDnBytes;
      FintUpBytes := intUpBytes;
    end;
  finally
    lsNetworkTraffic.Free;
    NetworkManager.Free;
  end;
end;

{ 获取本机网卡列表信息 }
function GetAdapterInfo(var lst: TList): Boolean;
var
  Adapters, Work: PIP_ADAPTER_INFO;
  BufLen        : ULONG;
  Ret           : DWORD;
begin
  Result := False;

  BufLen := 1024 * 15;
  GetMem(Adapters, BufLen);
  try
    repeat
      Ret := GetAdaptersInfo(Adapters, BufLen);
      case Ret of
        ERROR_SUCCESS:
          begin
            if BufLen = 0 then
              Exit;
            Break;
          end;

        ERROR_NOT_SUPPORTED, ERROR_NO_DATA:
          Exit;

        ERROR_BUFFER_OVERFLOW:
          ReallocMem(Adapters, BufLen);
      else
        SetLastError(Ret);
        RaiseLastOSError;
      end;
    until False;

    if Ret = ERROR_SUCCESS then
    begin
      Work := Adapters;
      repeat
        lst.Add(Work);
        Work := Work^.Next;
      until (Work = nil);
      Result := True;
    end;
  finally
    FreeMem(Adapters);
  end;
end;

{ 获取本机IP }
function GetNativeIP: String;
var
  lstAdapter  : TList;
  I           : Integer;
  AdapterInfo : PIP_ADAPTER_INFO;
  strGatewayIP: String;
  strIP       : String;
begin
  Result     := '';
  lstAdapter := TList.Create;
  try
    GetAdapterInfo(lstAdapter);
    if lstAdapter.Count <= 0 then
      Exit;

    for I := 0 to lstAdapter.Count - 1 do
    begin
      AdapterInfo  := PIP_ADAPTER_INFO(lstAdapter.Items[I]);
      strGatewayIP := string(AdapterInfo.GatewayList.IpAddress.s);
      strIP        := string(AdapterInfo.IpAddressList.IpAddress.s);
      if (not SameText(strGatewayIP, '0.0.0.0')) and (not SameText(strIP, '0.0.0.0')) then
      begin
        Result := strIP;
        Break;
      end;
    end;
  finally
    lstAdapter.Free;
  end;
end;

{ 获取当前网卡IP }
function GetCurrentAdapterIP: String;
var
  strName       : String;
  strIniFileName: String;
  I             : Integer;
  lstAdapter    : TList;
  AdapterInfo   : PIP_ADAPTER_INFO;
begin
  strIniFileName := ChangeFileExt(ParamStr(0), '.ini');
  with TIniFile.Create(strIniFileName) do
  begin
    strName := ReadString('Network', 'AdapterName', strName);
    Free;
  end;

  if Trim(strName) = '' then
  begin
    Result := GetNativeIP;
    Exit;
  end;

  lstAdapter := TList.Create;
  try
    GetAdapterInfo(lstAdapter);
    if lstAdapter.Count > 0 then
    begin
      for I := 0 to lstAdapter.Count - 1 do
      begin
        AdapterInfo := PIP_ADAPTER_INFO(lstAdapter.Items[I]);
        if SameText(string(AdapterInfo^.Description), strName) then
        begin
          Result := string(AdapterInfo^.IpAddressList.IpAddress.s);
          Break;
        end;
      end;
    end;
  finally
    lstAdapter.Free;
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

{ 排序父模块 }
procedure SortModuleParent(var lstModuleList: THashedStringList; const strPModuleList: String);
var
  lstTemp           : THashedStringList;
  I, J              : Integer;
  strPModuleName    : String;
  strOrderModuleName: String;
begin
  lstTemp := THashedStringList.Create;
  try
    for J := 0 to Length(strPModuleList.Split([';'])) - 1 do
    begin
      for I := lstModuleList.Count - 1 downto 0 do
      begin
        strPModuleName     := lstModuleList.ValueFromIndex[I].Split([';'])[0];
        strOrderModuleName := strPModuleList.Split([';'])[J];
        if CompareText(strOrderModuleName, strPModuleName) = 0 then
        begin
          lstTemp.Add(lstModuleList.Strings[I]);
          lstModuleList.Delete(I);
        end;
      end;
    end;

    { 有可能会有剩下的；后添加的新模块(父模块)，在未排序之前，是不在排序列表中的 }
    if lstModuleList.Count > 0 then
    begin
      for I := 0 to lstModuleList.Count - 1 do
      begin
        lstTemp.Add(lstModuleList.Strings[I]);
      end;
    end;

    lstModuleList.Clear;
    lstModuleList.Assign(lstTemp);
  finally
    lstTemp.Free;
  end;
end;

{ 交换位置 }
procedure SwapPosHashStringList(var lstModuleList: THashedStringList; const I, J: Integer);
var
  strTemp: String;
begin
  strTemp                  := lstModuleList.Strings[I];
  lstModuleList.Strings[I] := lstModuleList.Strings[J];
  lstModuleList.Strings[J] := strTemp;
end;

{ 查询指定模块的位置 }
function FindSubModuleIndex(const lstModuleList: THashedStringList; const strPModuleName, strSModuleName: String): Integer;
var
  I                  : Integer;
  strParentModuleName: String;
  strSubModuleName   : String;
begin
  Result := -1;
  for I  := 0 to lstModuleList.Count - 1 do
  begin
    strParentModuleName := lstModuleList.ValueFromIndex[I].Split([';'])[0];
    strSubModuleName    := lstModuleList.ValueFromIndex[I].Split([';'])[1];
    if (CompareText(strParentModuleName, strPModuleName) = 0) and (CompareText(strSubModuleName, strSModuleName) = 0) then
    begin
      Result := I;
      Break;
    end;
  end;
end;

{ 查询指定子模块的指定位置的索引号 }
function FindSubModulePos(const lstModuleList: THashedStringList; const strPModuleName: String; const intIndex: Integer): Integer;
var
  I, K               : Integer;
  strParentModuleName: String;
begin
  Result := -1;
  K      := -1;
  for I  := 0 to lstModuleList.Count - 1 do
  begin
    strParentModuleName := lstModuleList.ValueFromIndex[I].Split([';'])[0];
    if CompareText(strParentModuleName, strPModuleName) = 0 then
    begin
      Inc(K);
      if K = intIndex then
      begin
        Result := I;
        Break;
      end;
    end;
  end;
end;

{ 排序子模块 }
procedure SortSubModule_Proc(var lstModuleList: THashedStringList; const strPModuleName: String; const strSModuleOrder: string);
var
  I               : Integer;
  intNewIndex     : Integer;
  intOldIndex     : Integer;
  strSubModuleName: String;
begin
  for I := 0 to Length(strSModuleOrder.Split([';'])) - 1 do
  begin
    strSubModuleName := strSModuleOrder.Split([';'])[I];
    intNewIndex      := FindSubModuleIndex(lstModuleList, strPModuleName, strSubModuleName);
    intOldIndex      := FindSubModulePos(lstModuleList, strPModuleName, I);
    if (intNewIndex <> intOldIndex) and (intNewIndex > -1) and (intOldIndex > -1) then
    begin
      SwapPosHashStringList(lstModuleList, intNewIndex, intOldIndex);
    end;
  end;
end;

{ 排序子模块 }
procedure SortSubModule(var lstModuleList: THashedStringList; const strPModuleOrder: String; const iniModule: TIniFile);
var
  I, Count       : Integer;
  strPModuleName : String;
  strSModuleOrder: String;
begin
  Count := Length(strPModuleOrder.Split([';']));
  for I := 0 to Count - 1 do
  begin
    strPModuleName  := strPModuleOrder.Split([';'])[I];
    strSModuleOrder := iniModule.ReadString(c_strIniModuleSection, strPModuleName, '');
    if Trim(strSModuleOrder) <> '' then
    begin
      SortSubModule_Proc(lstModuleList, strPModuleName, strSModuleOrder);
    end;
  end;
end;

{ 排序模块 }
procedure SortModuleList(var lstDll: THashedStringList);
var
  strPModuleOrder: String;
  iniModule      : TIniFile;
begin
  iniModule := TIniFile.Create(ChangeFileExt(ParamStr(0), '.ini'));
  try
    { 排序父模块 }
    strPModuleOrder := iniModule.ReadString(c_strIniModuleSection, 'Order', '');
    if Trim(strPModuleOrder) <> '' then
      SortModuleParent(lstDll, strPModuleOrder);

    { 排序子模块 }
    SortSubModule(lstDll, strPModuleOrder, iniModule);
  finally
    iniModule.Free;
  end;
end;

{ TBaseForm }

procedure TBaseForm.CreateSubControl(pnl: TPanel);
begin
  { 时间 }
  FpnlTime             := TPanel.Create(pnl);
  FpnlTime.Parent      := pnl;
  FpnlTime.width       := 236;
  FpnlTime.Align       := alRight;
  FpnlTime.ShowCaption := False;
  FpnlTime.BevelOuter  := bvNone;
  FpnlTime.ParentColor := True;

  FBevelTime        := TBevel.Create(FpnlTime);
  FBevelTime.Parent := FpnlTime;
  FBevelTime.Align  := alLeft;
  FBevelTime.Shape  := bsLeftLine;

  FLabelTime              := TLabel.Create(FpnlTime);
  FLabelTime.Parent       := FpnlTime;
  FLabelTime.Left         := 8;
  FLabelTime.Top          := c_intTimeTop;
  FLabelTime.width        := 56;
  FLabelTime.Height       := 15;
  FLabelTime.Cursor       := crHandPoint;
  FLabelTime.Font.Name    := '宋体';
  FLabelTime.Font.Size    := 12;
  FLabelTime.Font.Charset := GB2312_CHARSET;
  FLabelTime.Font.Color   := clWhite;
  FLabelTime.OnClick      := OnTimeClick;

  FTimerTime          := TTimer.Create(nil);
  FTimerTime.Interval := 1000;
  FTimerTime.OnTimer  := OnTimerTime;

  { IP }
  FpmAdapterList             := TPopupMenu.Create(nil);
  FpmAdapterList.AutoHotkeys := maManual;
  FpmAdapterList.OwnerDraw   := True;

  FpnlIP             := TPanel.Create(pnl);
  FpnlIP.Parent      := pnl;
  FpnlIP.width       := 156;
  FpnlIP.Align       := alRight;
  FpnlIP.ShowCaption := False;
  FpnlIP.BevelOuter  := bvNone;
  FpnlIP.ParentColor := True;

  FBevelIP        := TBevel.Create(FpnlIP);
  FBevelIP.Parent := FpnlIP;
  FBevelIP.Align  := alLeft;
  FBevelIP.Shape  := bsLeftLine;

  FLabelIP              := TLabel.Create(FpnlIP);
  FLabelIP.Parent       := FpnlIP;
  FLabelIP.Left         := 8;
  FLabelIP.Top          := c_intTimeTop;
  FLabelIP.width        := 56;
  FLabelIP.Height       := 15;
  FLabelIP.Cursor       := crHandPoint;
  FLabelIP.Font.Name    := '宋体';
  FLabelIP.Font.Size    := 12;
  FLabelIP.Font.Charset := GB2312_CHARSET;
  FLabelIP.Font.Color   := clWhite;
  FLabelIP.OnMouseEnter := OnIPMouseEnter;
  FLabelIP.OnClick      := OnIPClick;

  { Web }
  FPnlLeftAll             := TPanel.Create(pnl);
  FPnlLeftAll.Parent      := pnl;
  FPnlLeftAll.Align       := alClient;
  FPnlLeftAll.BevelOuter  := bvNone;
  FPnlLeftAll.ParentColor := True;

  FpnlWeb             := TPanel.Create(FPnlLeftAll);
  FpnlWeb.Parent      := FPnlLeftAll;
  FpnlWeb.width       := 264;
  FpnlWeb.Align       := alRight;
  FpnlWeb.ShowCaption := False;
  FpnlWeb.BevelOuter  := bvNone;
  FpnlWeb.ParentColor := True;

  FBevelWeb        := TBevel.Create(FpnlWeb);
  FBevelWeb.Parent := FpnlWeb;
  FBevelWeb.Align  := alLeft;
  FBevelWeb.Shape  := bsLeftLine;

  FLabelWeb              := TLabel.Create(FpnlWeb);
  FLabelWeb.Parent       := FpnlWeb;
  FLabelWeb.Left         := 8;
  FLabelWeb.Top          := c_intTimeTop;
  FLabelWeb.width        := 56;
  FLabelWeb.Height       := 15;
  FLabelWeb.Font.Name    := '宋体';
  FLabelWeb.Font.Size    := 12;
  FLabelWeb.Font.Charset := GB2312_CHARSET;
  FLabelWeb.Font.Color   := clWhite;

  { login }
  Fpnllogin             := TPanel.Create(FPnlLeftAll);
  Fpnllogin.Parent      := FPnlLeftAll;
  Fpnllogin.width       := 264;
  Fpnllogin.Align       := alLeft;
  Fpnllogin.ShowCaption := False;
  Fpnllogin.BevelOuter  := bvNone;
  Fpnllogin.ParentColor := True;

  FLabellogin              := TLabel.Create(Fpnllogin);
  FLabellogin.Parent       := Fpnllogin;
  FLabellogin.Left         := 8;
  FLabellogin.Top          := c_intTimeTop - 2;
  FLabellogin.width        := 56;
  FLabellogin.Height       := 15;
  FLabellogin.Font.Name    := '宋体';
  FLabellogin.Font.Size    := 14;
  FLabellogin.Font.Charset := GB2312_CHARSET;
  FLabellogin.Font.Color   := clWhite;
  FLabellogin.Caption      := 'admin';
end;

procedure LoadBackground(img: TImage);
var
  strBackgroundFileName: String;
begin
  strBackgroundFileName := ExtractFilePath(ParamStr(0)) + 'back.jpg';
  if FileExists(strBackgroundFileName) then
  begin
    img.Picture.LoadFromFile(strBackgroundFileName);
  end
  else
  begin
    strBackgroundFileName := ExtractFilePath(ParamStr(0)) + 'back.png';
    if FileExists(strBackgroundFileName) then
    begin
      img.Picture.LoadFromFile(strBackgroundFileName)
    end
    else
    begin
      strBackgroundFileName := ExtractFilePath(ParamStr(0)) + 'back.bmp';
      if FileExists(strBackgroundFileName) then
        img.Picture.LoadFromFile(strBackgroundFileName);
    end;
  end;
end;

procedure TBaseForm.CreateSystemButton;
begin
  FbtnClose              := TImage.Create(FpnlTop);
  FbtnClose.Parent       := FpnlTop;
  FbtnClose.Top          := 2;
  FbtnClose.Left         := FbtnClose.Parent.width - 1 * c_intButtonWidth - 2;
  FbtnClose.AutoSize     := True;
  FbtnClose.Transparent  := False;
  FbtnClose.Hint         := '关闭';
  FbtnClose.ShowHint     := True;
  FbtnClose.Tag          := 0;
  FbtnClose.OnMouseEnter := OnSysBtnMouseEnter;
  FbtnClose.OnMouseLeave := OnSysBtnMouseLeave;
  FbtnClose.OnMouseDown  := OnSysBtnMouseDown;
  FbtnClose.OnClick      := OnSysBtnCloseClick;
  FbtnClose.Anchors      := [akRight, akTop];
  LoadButtonBmp(FbtnClose, 'CLOSE', 0);

  FbtnMax              := TImage.Create(FpnlTop);
  FbtnMax.Parent       := FpnlTop;
  FbtnMax.Top          := 2;
  FbtnMax.AutoSize     := True;
  FbtnMax.Left         := FbtnMax.Parent.width - 2 * c_intButtonWidth - 2;
  FbtnMax.Transparent  := False;
  FbtnMax.Hint         := '最大化';
  FbtnMax.ShowHint     := True;
  FbtnMax.Tag          := 1;
  FbtnMax.OnMouseEnter := OnSysBtnMouseEnter;
  FbtnMax.OnMouseLeave := OnSysBtnMouseLeave;
  FbtnMax.OnMouseDown  := OnSysBtnMouseDown;
  FbtnMax.OnClick      := OnSysBtnMaxClick;
  FbtnMax.Anchors      := [akRight, akTop];
  LoadButtonBmp(FbtnMax, 'MAX', 0);

  FbtnMin              := TImage.Create(FpnlTop);
  FbtnMin.Parent       := FpnlTop;
  FbtnMin.Top          := 2;
  FbtnMin.AutoSize     := True;
  FbtnMin.Left         := FbtnMin.Parent.width - 3 * c_intButtonWidth - 2;
  FbtnMin.Transparent  := False;
  FbtnMin.Hint         := '最小化';
  FbtnMin.ShowHint     := True;
  FbtnMin.Tag          := 2;
  FbtnMin.OnMouseEnter := OnSysBtnMouseEnter;
  FbtnMin.OnMouseLeave := OnSysBtnMouseLeave;
  FbtnMin.OnMouseDown  := OnSysBtnMouseDown;
  FbtnMin.OnClick      := OnSysBtnMinClick;
  FbtnMin.Anchors      := [akRight, akTop];
  LoadButtonBmp(FbtnMin, 'MINI', 0);

  FbtnConfig              := TImage.Create(FpnlTop);
  FbtnConfig.Parent       := FpnlTop;
  FbtnConfig.Top          := 2;
  FbtnConfig.AutoSize     := True;
  FbtnConfig.Left         := FbtnConfig.Parent.width - 4 * c_intButtonWidth - 2;
  FbtnConfig.Transparent  := False;
  FbtnConfig.Hint         := '配置';
  FbtnConfig.ShowHint     := True;
  FbtnConfig.Tag          := 3;
  FbtnConfig.OnMouseEnter := OnSysBtnMouseEnter;
  FbtnConfig.OnMouseLeave := OnSysBtnMouseLeave;
  FbtnConfig.OnMouseDown  := OnSysBtnMouseDown;
  FbtnConfig.OnClick      := OnSysBtnConfigClick;
  FbtnConfig.Anchors      := [akRight, akTop];
  LoadButtonBmp(FbtnConfig, 'CONFIG', 0);
end;

procedure LoadLogo(img: TImage);
var
  strLogoFileName: String;
begin
  TPanel(img).ShowCaption := False;
  strLogoFileName         := ExtractFilePath(ParamStr(0)) + 'logo.jpg';
  if FileExists(strLogoFileName) then
  begin
    img.Picture.LoadFromFile(strLogoFileName);
  end
  else
  begin
    strLogoFileName := ExtractFilePath(ParamStr(0)) + 'logo.png';
    if FileExists(strLogoFileName) then
    begin
      img.Picture.LoadFromFile(strLogoFileName)
    end
    else
    begin
      strLogoFileName := ExtractFilePath(ParamStr(0)) + 'logo.bmp';
      if FileExists(strLogoFileName) then
      begin
        img.Picture.LoadFromFile(strLogoFileName);
      end
      else
      begin
        TPanel(img).Caption     := c_strTitle;
        TPanel(img).ShowCaption := True;
      end;
    end;
  end;
end;

constructor TBaseForm.Create(AOwner: TComponent);
begin
  inherited;

  BorderStyle       := bsNone;
  FbMaxForm         := False;
  Caption           := c_strTitle;
  Application.Title := c_strTitle;
  width             := 1024;
  Height            := 700;

  FpnlTop                  := TPanel.Create(nil);
  FpnlTop.Parent           := Self;
  FpnlTop.Name             := 'pnlTop';
  FpnlTop.Align            := alTop;
  FpnlTop.Height           := 80;
  FpnlTop.Color            := RGB(46, 141, 230);
  FpnlTop.ParentColor      := False;
  FpnlTop.ParentBackground := False;
  FpnlTop.BevelOuter       := bvNone;
  FpnlTop.OnMouseDown      := pnlMouseDown;
  FpnlTop.OnMouseUp        := pnlMouseUp;
  FpnlTop.OnMouseMove      := pnlMouseMove;
  FpnlTop.OnDblClick       := pnlDBLClick;
  FpnlTop.Caption          := c_strTitle;
  FpnlTop.Font.Name        := '宋体';
  FpnlTop.Font.Size        := 18;
  FpnlTop.Font.Style       := FpnlTop.Font.Style + [fsBold];
  FpnlTop.Font.Color       := clWhite;
  FimgLogo                 := TImage.Create(FpnlTop);
  FimgLogo.Parent          := FpnlTop;
  FimgLogo.Align           := alClient;
  FimgLogo.Center          := False;
  FimgLogo.Stretch         := False;
  FimgLogo.AutoSize        := True;
  FimgLogo.OnMouseDown     := pnlMouseDown;
  FimgLogo.OnMouseUp       := pnlMouseUp;
  FimgLogo.OnMouseMove     := pnlMouseMove;
  FimgLogo.OnDblClick      := pnlDBLClick;
  LoadLogo(FimgLogo);

  FpnlBottom                  := TPanel.Create(nil);
  FpnlBottom.Parent           := Self;
  FpnlBottom.Name             := 'pnlBottom';
  FpnlBottom.Align            := alBottom;
  FpnlBottom.Height           := 28;
  FpnlBottom.ShowCaption      := False;
  FpnlBottom.Color            := RGB(46, 141, 230);
  FpnlBottom.ParentColor      := False;
  FpnlBottom.ParentBackground := False;
  FpnlBottom.BevelOuter       := bvNone;
  FpnlBottom.OnMouseDown      := pnlMouseDown;
  FpnlBottom.OnMouseUp        := pnlMouseUp;
  FpnlBottom.OnMouseMove      := pnlMouseMove;
  FpnlBottom.OnDblClick       := pnlDBLClick;
  CreateSubControl(FpnlBottom);

  { 创建系统按钮 }
  CreateSystemButton;

  OnTimerTime(nil);
  FLabelIP.Caption := GetCurrentAdapterIP;

  { 设置 DLL 路径 }
  SetDllDirectory(PChar(ExtractFilePath(ParamStr(0)) + 'plugins'));
end;

destructor TBaseForm.Destroy;
begin
  FbtnConfig.Free;
  FbtnMin.Free;
  FbtnMax.Free;
  FbtnClose.Free;
  FimgLogo.Free;
  FpnlTop.Free;

  FpmAdapterList.Free;
  FBevelIP.Free;
  FLabelIP.Free;
  FpnlIP.Free;

  FTimerTime.Free;
  FLabelTime.Free;
  FBevelTime.Free;
  FpnlTime.Free;

  FLabelWeb.Free;
  FBevelWeb.Free;
  FpnlWeb.Free;

  FLabellogin.Free;
  Fpnllogin.Free;

  FPnlLeftAll.Free;
  FpnlBottom.Free;
  inherited;
end;

procedure TBaseForm.pnlMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FbMouseDown := True;
  GetCursorPos(FptOld);
end;

function TBaseForm.IsMouseLButtonDown(): Boolean;
begin
  Result := (GetAsyncKeyState(VK_LBUTTON) and $FF00) > 0;
end;

procedure TBaseForm.LoadButtonBmp(btn: TImage; const strResName: String; const intIndex: Integer);
var
  bmp      : TBitmap;
  bmpButton: TBitmap;
  memBMP   : TResourceStream;
begin
  memBMP    := TResourceStream.Create(HInstance, 'SYSBUTTON_' + strResName, RT_RCDATA);
  bmp       := TBitmap.Create;
  bmpButton := TBitmap.Create;
  try
    bmp.LoadFromStream(memBMP);;
    bmpButton.width  := bmp.width div 3;
    bmpButton.Height := bmp.Height;
    bmpButton.Canvas.CopyRect(bmpButton.Canvas.ClipRect, bmp.Canvas, Rect(c_intButtonWidth * intIndex, 0, c_intButtonWidth * intIndex + bmpButton.width, bmpButton.Height));
    btn.Picture.Bitmap.Assign(bmpButton);
  finally
    memBMP.Free;
    bmpButton.Free;
    bmp.Free;
  end;
end;

procedure TBaseForm.OnSysBtnCloseClick(Sender: TObject);
begin
  PostMessage(Handle, WM_SYSCOMMAND, SC_CLOSE, 0);
end;

procedure TBaseForm.OnSysBtnConfigClick(Sender: TObject);
var
  img: TImage;
  pt : TPoint;
begin
  if Assigned(FTrayMenu) then
  begin
    img  := TImage(Sender);
    pt.X := Left + img.Left + 8;
    pt.Y := Top + img.Top + img.Height;
    FTrayMenu.Popup(pt.X, pt.Y);
  end;
end;

procedure TBaseForm.OnSysBtnMaxClick(Sender: TObject);
begin
  if not FbMaxForm then
  begin
    FbMaxForm := not FbMaxForm;
    FOldPos.X := Left;
    FOldPos.Y := Top;
    FormMaxSize;
    TImage(Sender).Hint := '还原';
    LoadButtonBmp(TImage(Sender), 'RESTORE', 0);
  end
  else
  begin
    FbMaxForm := not FbMaxForm;
    FormNormalSize;
    TImage(Sender).Hint := '最大化';
    LoadButtonBmp(TImage(Sender), 'MAX', 0);
  end;
end;

procedure TBaseForm.OnSysBtnMinClick(Sender: TObject);
begin
  PostMessage(Handle, WM_SYSCOMMAND, SC_MINIMIZE, 0);
end;

function GetSysButonType(img: TImage): String;
const
  c_strButtonName: array [0 .. 3] of string = ('CLOSE', 'MAX', 'MINI', 'CONFIG');
begin
  Result := c_strButtonName[img.Tag];
end;

procedure TBaseForm.OnSysBtnMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (TImage(Sender).Tag = 1) and FbMaxForm then
    LoadButtonBmp(TImage(Sender), 'RESTORE', 2)
  else
    LoadButtonBmp(TImage(Sender), GetSysButonType(TImage(Sender)), 2);
end;

procedure TBaseForm.OnSysBtnMouseEnter(Sender: TObject);
begin
  if (TImage(Sender).Tag = 1) and FbMaxForm then
    LoadButtonBmp(TImage(Sender), 'RESTORE', 1)
  else
    LoadButtonBmp(TImage(Sender), GetSysButonType(TImage(Sender)), 1);
end;

procedure TBaseForm.OnSysBtnMouseLeave(Sender: TObject);
begin
  if (TImage(Sender).Tag = 1) and FbMaxForm then
    LoadButtonBmp(TImage(Sender), 'RESTORE', 0)
  else
    LoadButtonBmp(TImage(Sender), GetSysButonType(TImage(Sender)), 0);
end;

procedure TBaseForm.pnlMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  ptNew: TPoint;
begin
  if FbMaxForm then
    Exit;

  if not FbMouseDown then
    Exit;

  if not IsMouseLButtonDown then
  begin
    FbMouseDown := False;
    Exit;
  end;

  GetCursorPos(ptNew);
  Top    := Top + ptNew.Y - FptOld.Y;
  Left   := Left + ptNew.X - FptOld.X;
  FptOld := ptNew;
end;

procedure TBaseForm.pnlMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FbMouseDown := False;
end;

procedure TBaseForm.WMSYSCOMMAND(var msg: TWMSYSCOMMAND);
begin
  case msg.CmdType of
    SC_RESTORE:
      SetWindowLong(Handle, GWL_STYLE, GetWindowLong(Handle, GWL_STYLE) OR WS_MINIMIZEBOX);
    SC_MINIMIZE:
      SetWindowLong(Handle, GWL_STYLE, GetWindowLong(Handle, GWL_STYLE) OR WS_MAXIMIZEBOX);
  end;
  inherited;
end;

procedure TBaseForm.FormMaxSize;
begin
  Left := Screen.MonitorFromWindow(Handle).WorkAreaRect.Left;
  Top  := Screen.MonitorFromWindow(Handle).WorkAreaRect.Top;
  DelayTime(100);
  WindowState := TWindowState.wsMaximized;
end;

procedure TBaseForm.FormNormalSize;
begin
  WindowState := TWindowState.wsNormal;
  Left        := FOldPos.X;
  Top         := FOldPos.Y;
end;

procedure TBaseForm.pnlDBLClick(Sender: TObject);
begin
  FbtnMax.OnClick(FbtnMax);
end;

procedure TBaseForm.DelayTime(const intTime: Cardinal);
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

procedure TBaseForm.OnTimeClick(Sender: TObject);
begin
  WinExec(PAnsiChar('rundll32.exe Shell32.dll,Control_RunDLL intl.cpl,,/p:"date"'), SW_SHOW);
end;

procedure TBaseForm.OnTimerTime(Sender: TObject);
const
  WeekDay: array [1 .. 7] of String = ('星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六');
{$IFDEF RELEASE}
var
  strWebDownSpeed, strWebUpSpeed: String;
{$ENDIF}
begin
  FLabelTime.Caption := DateTimeToStr(Now) + ' ' + WeekDay[DayOfWeek(Now)];
{$IFDEF RELEASE}
  GetWebSpeed(strWebDownSpeed, strWebUpSpeed);
  FLabelWeb.Caption := Format('↓：%s  ↑：%s', [strWebDownSpeed, strWebUpSpeed]);
{$ENDIF}
end;

procedure TBaseForm.OnIPClick(Sender: TObject);
var
  lstAdapter : TList;
  I          : Integer;
  AdapterInfo: PIP_ADAPTER_INFO;
  strIP      : String;
  strGate    : String;
  strName    : String;
  mmItem     : TMenuItem;
  pt         : TPoint;
begin
  lstAdapter := TList.Create;
  try
    GetAdapterInfo(lstAdapter);
    if lstAdapter.Count > 0 then
    begin
      FpmAdapterList.Items.Clear;
      for I := 0 to lstAdapter.Count - 1 do
      begin
        AdapterInfo       := PIP_ADAPTER_INFO(lstAdapter.Items[I]);
        strIP             := string(AdapterInfo^.IpAddressList.IpAddress.s);
        strGate           := string(AdapterInfo^.GatewayList.IpAddress.s);
        strName           := string(AdapterInfo^.Description);
        mmItem            := TMenuItem.Create(FpmAdapterList);
        mmItem.Caption    := Format('IP: ' + '%-16s Gate: %-16s Name: %-120s', [strIP, strGate, strName]);
        mmItem.OnDrawItem := OnAdapterDrawItem;
        mmItem.OnClick    := OnAdapterIPClick;
        FpmAdapterList.Items.Add(mmItem);
      end;
      if FpmAdapterList.Items.Count > 1 then
      begin
        pt.X := FpnlIP.Left + Left;
        pt.Y := Top + Height + 2;
        FpmAdapterList.Popup(pt.X, pt.Y);
      end;
    end;
  finally
    lstAdapter.Free;
  end;
end;

procedure TBaseForm.OnIPMouseEnter(Sender: TObject);
var
  lstAdapter: TList;
begin
  lstAdapter := TList.Create;
  try
    GetAdapterInfo(lstAdapter);
    FLabelIP.Cursor := Ifthen(lstAdapter.Count > 1, crHandPoint, crDefault);
  finally
    lstAdapter.Free;
  end;
end;

procedure TBaseForm.OnAdapterDrawItem(Sender: TObject; ACanvas: TCanvas; ARect: TRect; Selected: Boolean);
begin
  ACanvas.Font.Name := '宋体';
  ACanvas.Font.Size := 11;
  ACanvas.TextOut(ARect.Left, ARect.Top, (Sender as TMenuItem).Caption);
end;

procedure TBaseForm.OnAdapterIPClick(Sender: TObject);
var
  strText       : string;
  strIP         : String;
  strName       : String;
  strIniFileName: String;
begin
  strText          := (Sender as TMenuItem).Caption;
  strIP            := Trim(LeftStr(strText, 19));
  strIP            := RightStr(strIP, Length(strIP) - 4);
  FLabelIP.Caption := strIP;

  strName        := Trim(RightStr(strText, Length(strText) - 42));
  strName        := RightStr(strName, Length(strName) - 6);
  strIniFileName := ChangeFileExt(ParamStr(0), '.ini');
  with TIniFile.Create(strIniFileName) do
  begin
    WriteString('Network', 'AdapterName', strName);
    Free;
  end;
end;

{ 显示登录窗体 }
function ShowLoginForm(OnCheckPassword: TOnCheckPassword): String;
var
  strDBEngineDllFileName: String;
  hDll                  : HMODULE;
  pFunc                 : function(OnCheckPassword: TOnCheckPassword): PAnsiChar; stdcall;
begin
  strDBEngineDllFileName := ExtractFilePath(ParamStr(0)) + 'plugins\dbe.dll';
  if not FileExists(strDBEngineDllFileName) then
    Exit;

  hDll := LoadLibrary(PChar(strDBEngineDllFileName));
  if hDll = INVALID_HANDLE_VALUE then
    Exit;

  try
    pFunc := GetProcaddress(hDll, 'ShowLoginForm');
    if @pFunc = nil then
      Exit;

    Result := String(pFunc(OnCheckPassword));
  finally
    FreeLibrary(hDll);
  end;
end;

end.
