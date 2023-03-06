unit frmMain;

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.IpTypes, System.SysUtils, System.Classes, System.IniFiles, System.UITypes, System.StrUtils, System.Math, System.ImageList,
  Vcl.Graphics, Vcl.Buttons, Vcl.Controls, Vcl.Forms, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Menus, Vcl.StdCtrls, Vcl.ToolWin, Vcl.ImgList, IdHashMessageDigest, uBaseForm;

{ �û���¼����������Ƿ���ȷ }
function MyOnCheckPassword(const strPassword: PAnsiChar): PAnsiChar; stdcall;

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
    { �������е� DLL �� EXE ���б� }
    procedure LoadAllPlugins(var lstDll: THashedStringList);
    { ����ģ�鹦�ܲ˵� }
    procedure CreateMenu(const listDll: THashedStringList);
    { ���� UI }
    procedure CreateUI(const lst: THashedStringList);
    { �ͷ��Ѿ������� DLL Form ���� }
    procedure FreeDllForm;
    { �ͷŴ����Ĳ˵���Դ }
    procedure FreeMenu;
    { ������ʾ���� }
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
  FLabellogin.Caption := string(FstrUserLoginName);
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

  { �ж��Ƿ��� DLL �Ĵ����� }
  if GetParent(hDllForm) = 0 then
  begin
    GetWindowRect(hParentHandle, rctClient);
    SetWindowPos(hDllForm, hParentHandle, 0, 0, rctClient.Width, rctClient.Height, SWP_NOZORDER + SWP_NOACTIVATE);
    PostMessage(hDllForm, WM_NCACTIVATE, 1, 0);
  end;
end;

{ �� DLL / EXE ����ʱ������ DLL / EXE �����С }
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
  { �������е� DLL �� EXE ģ�鵽�б� }
  LoadAllPlugins(FlistModuleDll);

  { ���� UI }
  CreateUI(FlistModuleDll);
end;

procedure TfrmPBox.LoadAllPlugins(var lstDll: THashedStringList);
begin
  { �Ƿ����˼��ټ�����ģ�� }
  if CheckLoadSpeed then
  begin
    lstDll.LoadFromFile(GetLoadSpeedFileName_Config);
    LoadAllMenuIconSpeed(ilMainMenu);
  end
  else
  begin
    { ������������ DLL ģ�� }
    LoadAllDLLPlugins(lstDll, ilMainMenu);

    { ������������ EXE ģ�� }
    LoadAllEXEPlugins(lstDll, ilMainMenu);

    { ����ģ�� }
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

{ �ͷŴ����Ĳ˵���Դ }
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

    { ������˵������ڣ��������˵� }
    mmPM := mmMainMenu.Items.Find(string(strPModuleName));
    if mmPM = nil then
    begin
      mmPM         := TMenuItem.Create(Self);
      mmPM.Caption := string((strPModuleName));
      mmMainMenu.Items.Add(mmPM);
    end;

    { �����Ӳ˵� }
    mmSM            := TMenuItem.Create(Self);
    mmSM.Caption    := string((strSModuleName));
    mmSM.Tag        := I;
    mmSM.ImageIndex := intIconIndex;
    mmSM.OnClick    := OnMenuItemClick;
    mmPM.Add(mmSM);
  end;
end;

{ ������ʾ���� }
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

{ ���� UI }
procedure TfrmPBox.CreateUI(const lst: THashedStringList);
begin
  { ����ģ�鹦�ܲ˵� }
  CreateMenu(lst);

  { ������ʾ���� }
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
      ShowDelphiDllForm(strDllFileFullPath, tsDll);                              // ���� Delphi DLL Form
    lsVCDLGDll:                                                                  //
      ShowVCDLGDllForm(strDllFileFullPath, tsDll);                               // ���� VC DLG DLL Form
    lsVCMFCDll:                                                                  //
      ShowVCMFCDllForm(strDllFileFullPath, tsDll);                               // ���� VC MFC DLL Form
    lsQTDll:                                                                     //
      ShowVCDLGDllForm(strDllFileFullPath, tsDll);                               // ���� QT DLG DLL Form
    lsEXE:                                                                       //
      ShowEXEForm(strFileName, strEXEFormClassName, strEXEFormTitleName, tsDll); // ���� EXE Form
  end;
end;

{ ���Լ������ݿ�����㷨 }
function TestPassowrd_MD5String(const Astr: String): String;
var
  MemSteam: TMemoryStream;
  MyMD5   : TIdHashMessageDigest5;
  B       : Tbytes;
  n       : Integer;
begin
  B := BytesOf(Astr);
  n := Length(B);

  MemSteam := TMemoryStream.Create;
  Try
    MemSteam.SetSize(n);
    MemSteam.Position := 0;
    MemSteam.Write(B[0], n);
    MemSteam.Position := 0;
    MyMD5             := TIdHashMessageDigest5.Create;
    Try
      Result := MyMD5.HashStreamAsHex(MemSteam);
    Finally
      MyMD5.Free;
    End;
  Finally
    MemSteam.Free;
    SetLength(B, 0);
  End;
end;

{ �û���¼����������Ƿ���ȷ }
function MyOnCheckPassword(const strPassword: PAnsiChar): PAnsiChar; stdcall;
begin
  Result := PAnsiChar(AnsiString(TestPassowrd_MD5String(Trim(string(strPassword)))));
end;

end.
