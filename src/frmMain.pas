unit frmMain;

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.IpTypes, System.SysUtils, System.Classes, System.IniFiles, System.UITypes, System.StrUtils, System.Math, System.ImageList,
  Vcl.Graphics, Vcl.Buttons, Vcl.Controls, Vcl.Forms, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Menus, Vcl.StdCtrls, Vcl.ToolWin, Vcl.ImgList, uBaseForm;

type
  TfrmPBox = class(TBaseForm)
    clbrPModule: TCoolBar;
    tlbMenu: TToolBar;
    pgcAll: TPageControl;
    tsButton: TTabSheet;
    pnlModuleDialog: TPanel;
    pnlModuleDialogTitle: TPanel;
    imgSubModuleClose: TImage;
    tsCenter: TTabSheet;
    tsDll: TTabSheet;
    tsList: TTabSheet;
    ctgrypnlgrpModule: TCategoryPanelGroup;
    tsWelcome: TTabSheet;
    pmTray: TPopupMenu;
    mniFuncMenuConfig: TMenuItem;
    mniFuncMenuMoney: TMenuItem;
    mniFuncMenuLine01: TMenuItem;
    mniFuncMenuAbout: TMenuItem;
    mmMainMenu: TMainMenu;
    ilMainMenu: TImageList;
    ilPModule: TImageList;
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure imgSubModuleCloseMouseEnter(Sender: TObject);
    procedure imgSubModuleCloseMouseLeave(Sender: TObject);
    procedure imgSubModuleCloseClick(Sender: TObject);
    procedure mniFuncMenuConfigClick(Sender: TObject);
    procedure mniFuncMenuMoneyClick(Sender: TObject);
    procedure mniFuncMenuAboutClick(Sender: TObject);
  private
    FbChangeUI    : Boolean;
    FlistModuleDll: THashedStringList;
    procedure InitPageAll;
    procedure ReCreate;
    procedure OnMenuItemClick(Sender: TObject);
    { 加载所有的 DLL 和 EXE 到列表 }
    procedure LoadAllPlugins(var lstDll: THashedStringList);
    { 排序模块 }
    procedure SortModuleList(var lstDll: THashedStringList);
    { 创建模块功能菜单 }
    procedure CreateMenu(const listDll: THashedStringList);
    { 创建 UI }
    procedure CreateUI(const lst: THashedStringList);
    { 释放已经创建的 DLL Form 窗体 }
    procedure FreeDllForm;
    { 释放创建的菜单资源 }
    procedure FreeMenu;
    { 创建显示界面 }
    procedure CreateUIStyle;
  end;

var
  frmPBox: TfrmPBox;

implementation

uses uDllDelphi, uDllVCDLG, uDllVCMFC, uExeForm, uUICreate, frmAbout, frmDonate, frmConfig;

{$R *.dfm}

procedure TfrmPBox.InitPageAll;
var
  I: Integer;
begin
  for I := 0 to pgcAll.PageCount - 1 do
  begin
    pgcAll.Pages[I].TabVisible := False;
  end;
  pgcAll.ActivePage := tsWelcome;
end;

procedure TfrmPBox.FormCreate(Sender: TObject);
begin
  FbChangeUI := False;
  InitPageAll;
end;

procedure TfrmPBox.FormActivate(Sender: TObject);
begin
  FLabellogin.Caption := 'dbyoung';
  TrayMenu            := pmTray;
  FlistModuleDll      := THashedStringList.Create;
  LoadButtonBmp(imgSubModuleClose, 'Close', 0);
  ReCreate;
end;

procedure TfrmPBox.FormDestroy(Sender: TObject);
begin
  FreeUIButtonResource(tlbMenu);
  FreeDllForm;
  FreeMenu;
  FlistModuleDll.Free;
end;

function EnumChildFunc(hDllForm: THandle; hParentHandle: THandle): Boolean; stdcall;
var
  rctClient: TRect;
begin
  Result := True;

  { 判断是否是 DLL 的窗体句柄 }
  if GetParent(hDllForm) = 0 then
  begin
    GetWindowRect(hParentHandle, rctClient);
    SetWindowPos(hDllForm, hParentHandle, 0, 0, rctClient.Width, rctClient.Height, SWP_NOZORDER + SWP_NOACTIVATE);
    PostMessage(hDllForm, WM_NCACTIVATE, 1, 0);
  end;
end;

{ 有 DLL / EXE 窗体时，更改 DLL / EXE 窗体大小 }
procedure TfrmPBox.FormResize(Sender: TObject);
var
  bakActiveTabSheet: TTabSheet;
begin
  { BUTTON UI }
  if GetCurrUIStyle = uiButton then
  begin
    if Assigned(pnlModuleDialog) then
    begin
      pnlModuleDialog.Left := (pnlModuleDialog.Parent.Width - pnlModuleDialog.Width) div 2;
      if Assigned(Sender) then
        pnlModuleDialog.Top := (pnlModuleDialog.Parent.Height - pnlModuleDialog.Height) div 2
      else
        pnlModuleDialog.Top := (pnlModuleDialog.Parent.Height - 19 - pnlModuleDialog.Height) div 2;
    end;
  end;

  { Center UI }
  if (GetCurrUIStyle = uiCenter) and (Application.MainForm <> nil) then
  begin
    bakActiveTabSheet := pgcAll.ActivePage;
    CreateUIStyle;
    if bakActiveTabSheet = tsDll then
      pgcAll.ActivePage := tsDll;
  end;

  { DLL Form }
  if (Assigned(pgcAll)) and (Assigned(tsDll)) and (pgcAll.ActivePage = tsDll) then
  begin
    EnumChildWindows(Handle, @EnumChildFunc, tsDll.Handle);
  end;
end;

procedure TfrmPBox.FreeDllForm;
begin
  CheckLastVCDLGDllClose;
  CheckLastVCMFCDllClose;
  CheckLastDelphiDllClose;
  CheckLastExeFormClose;
end;

procedure TfrmPBox.imgSubModuleCloseClick(Sender: TObject);
var
  I: Integer;
begin
  pnlModuleDialog.Visible := False;
  for I                   := 0 to tlbMenu.ButtonCount - 1 do
  begin
    tlbMenu.Buttons[I].Down := False;
  end;
end;

procedure TfrmPBox.imgSubModuleCloseMouseEnter(Sender: TObject);
begin
  LoadButtonBmp(imgSubModuleClose, 'Close', 1);
end;

procedure TfrmPBox.imgSubModuleCloseMouseLeave(Sender: TObject);
begin
  LoadButtonBmp(imgSubModuleClose, 'Close', 0);
end;

procedure TfrmPBox.ReCreate;
begin
  { 加载所有的 DLL 和 EXE 模块到列表 }
  LoadAllPlugins(FlistModuleDll);

  { 创建 UI }
  CreateUI(FlistModuleDll);
end;

procedure TfrmPBox.LoadAllPlugins(var lstDll: THashedStringList);
begin
  { 是否开启了加速加载子模块 }
  if CheckLoadSpeed then
  begin
    lstDll.LoadFromFile(GetLoadSpeedFileName_Config);
    LoadAllMenuIconSpeed(ilMainMenu);
  end
  else
  begin
    { 搜索加载所有 DLL 模块 }
    LoadAllDLLPlugins(lstDll, ilMainMenu);

    { 搜索加载所有 EXE 模块 }
    LoadAllEXEPlugins(lstDll, ilMainMenu);

    { 排序模块 }
    SortModuleList(FlistModuleDll);
  end;
end;

procedure TfrmPBox.mniFuncMenuAboutClick(Sender: TObject);
begin
  ShowAboutForm;
end;

procedure TfrmPBox.mniFuncMenuMoneyClick(Sender: TObject);
begin
  ShowDonateForm;
end;

procedure TfrmPBox.mniFuncMenuConfigClick(Sender: TObject);
begin
  if ShowConfigForm(FlistModuleDll, ilMainMenu) then
  begin
    FbChangeUI := True;
    FreeUIButtonResource(tlbMenu);
    FreeDllForm;
    FreeMenu;
    FlistModuleDll.Clear;
    ReCreate;
  end;
end;

{ 排序模块 }
procedure TfrmPBox.SortModuleList(var lstDll: THashedStringList);
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

{ 释放创建的菜单资源 }
procedure TfrmPBox.FreeMenu;
var
  I              : Integer;
  J              : Integer;
  mmParent, mmSub: TMenuItem;
begin
  mmMainMenu.AutoMerge := False;
  for I                := mmMainMenu.Items.Count - 1 downto 0 do
  begin
    mmParent := mmMainMenu.Items.Items[I];
    for J    := mmParent.Count - 1 downto 0 do
    begin
      mmSub := mmParent.Items[J];
      mmSub.Free;
    end;
    mmParent.Free;
  end;
  mmMainMenu.Items.Clear;
  mmMainMenu.AutoMerge := False;
end;

procedure TfrmPBox.CreateMenu(const listDll: THashedStringList);
var
  I             : Integer;
  strInfo       : String;
  strPModuleName: String;
  strSModuleName: String;
  mmPM          : TMenuItem;
  mmSM          : TMenuItem;
  intIconIndex  : Integer;
begin
  tlbMenu.Menu := nil;
  FreeMenu;
  for I := 0 to listDll.Count - 1 do
  begin
    strInfo        := listDll.ValueFromIndex[I];
    strPModuleName := strInfo.Split([';'])[0];
    strSModuleName := strInfo.Split([';'])[1];
    intIconIndex   := StrToInt(strInfo.Split([';'])[4]);

    { 如果父菜单不存在，创建父菜单 }
    mmPM := mmMainMenu.Items.Find(string(strPModuleName));
    if mmPM = nil then
    begin
      mmPM         := TMenuItem.Create(Self);
      mmPM.Caption := string((strPModuleName));
      mmMainMenu.Items.Add(mmPM);
    end;

    { 创建子菜单 }
    mmSM            := TMenuItem.Create(Self);
    mmSM.Caption    := string((strSModuleName));
    mmSM.Tag        := I;
    mmSM.ImageIndex := intIconIndex;
    mmSM.OnClick    := OnMenuItemClick;
    mmPM.Add(mmSM);
  end;
end;

{ 创建显示界面 }
procedure TfrmPBox.CreateUIStyle;
var
  UI: TUIType;
begin
  UI := GetCurrUIStyle;
  case UI of
    uiMenu:
      CreateUIType_Menu(mmMainMenu, tlbMenu, pgcAll, ilMainMenu);
    uiButton:
      CreateUIType_Button(mmMainMenu, tlbMenu, ilMainMenu, ilPModule, pnlModuleDialog, pgcAll, FreeDllForm);
    uiList:
      CreateUIType_List(ctgrypnlgrpModule, mmMainMenu, tlbMenu, ilMainMenu, pgcAll);
    uiCenter:
      CreateUIType_Center(mmMainMenu, tlbMenu, ilMainMenu, pgcAll, FbChangeUI);
  end;
end;

{ 创建 UI }
procedure TfrmPBox.CreateUI(const lst: THashedStringList);
begin
  { 创建模块功能菜单 }
  CreateMenu(lst);

  { 创建显示界面 }
  CreateUIStyle;
end;

procedure TfrmPBox.OnMenuItemClick(Sender: TObject);
var
  intIndex           : Integer;
  strFileName        : string;
  strDllFileFullPath : String;
  strEXEFormClassName: String;
  strEXEFormTitleName: String;
  lsType             : TLangStyle;
begin
  FreeDllForm;

  intIndex            := TMenuItem(Sender).Tag;
  strFileName         := FlistModuleDll.Names[intIndex];
  strDllFileFullPath  := ExtractFilePath(ParamStr(0)) + 'plugins\' + strFileName;
  strEXEFormClassName := FlistModuleDll.ValueFromIndex[intIndex].Split([';'])[2];
  strEXEFormTitleName := FlistModuleDll.ValueFromIndex[intIndex].Split([';'])[3];

  lsType := TLangStyle(StrToInt(FlistModuleDll.ValueFromIndex[intIndex].Split([';'])[5]));
  case lsType of
    lsDelphiDll:
      ShowDelphiDllForm(strDllFileFullPath, tsDll);                              // 创建 Delphi DLL Form
    lsVCDLGDll:                                                                  //
      ShowVCDLGDllForm(strDllFileFullPath, tsDll);                               // 创建 VC DLG DLL Form
    lsVCMFCDll:                                                                  //
      ShowVCMFCDllForm(strDllFileFullPath, tsDll);                               // 创建 VC MFC DLL Form
    lsQTDll:                                                                     //
      ShowVCDLGDllForm(strDllFileFullPath, tsDll);                               // 创建 QT DLG DLL Form
    lsEXE:                                                                       //
      ShowEXEForm(strFileName, strEXEFormClassName, strEXEFormTitleName, tsDll); // 创建 EXE Form
  end;
end;

end.
