unit uUICreate;
{
  Func : UI Create / Free Manager
  Auth : dbyoung@sina.com
  Time : 2023-02-20
}

interface

uses
  Winapi.Windows, Winapi.Messages, System.Classes, System.SysUtils, System.StrUtils, System.IniFiles, System.Math, System.UITypes,
  Vcl.Forms, Vcl.Menus, Vcl.ComCtrls, Vcl.Controls, Vcl.ExtCtrls, Vcl.Graphics, Vcl.Buttons, Vcl.StdCtrls, uBaseForm;

{ 菜单风格 UI }
procedure CreateUIType_Menu(mmMain: TMainMenu; tlbMenu: TToolBar; pgAll: TPageControl; ilMainMenu: TImageList);

{ 按钮风格 UI }
procedure CreateUIType_Button(mmMain: TMainMenu; tlbMenu: TToolBar; ilMainMenu, ilPModule: TImageList; pnlButton: TPanel; pgcAll: TPageControl; FreeDllForm: TCallFunc);

{ 列表风格 UI }
procedure CreateUIType_List(ctgrypnlgrpModule: TCategoryPanelGroup; mmMain: TMainMenu; tlbMenu: TToolBar; ilMainMenu: TImageList; pgcAll: TPageControl);

{ 中心风格 UI }
procedure CreateUIType_Center(mmMain: TMainMenu; tlbMenu: TToolBar; ilMainMenu: TImageList; pgcAll: TPageControl; var bChangeUI: Boolean);

procedure FreeUIButtonResource(tlbMenu: TToolBar);

implementation

{ 菜单风格 UI }
procedure CreateUIType_Menu(mmMain: TMainMenu; tlbMenu: TToolBar; pgAll: TPageControl; ilMainMenu: TImageList);
begin
  tlbMenu.Menu           := mmMain;
  tlbMenu.Images         := nil;
  tlbMenu.Height         := 24;
  tlbMenu.Parent.Visible := True;
  mmMain.AutoMerge       := True;
  pgAll.ActivePageIndex  := 0;
end;

var
  FExitParentToolButton: TToolButton         = nil;
  FFreeDllForm         : TCallFunc           = nil;
  FmmMain              : TMainMenu           = nil;
  FilMainMenu          : TImageList          = nil;
  FpnlModuleDialog     : TPanel              = nil;
  FctgrypnlgrpModule   : TCategoryPanelGroup = nil;
  FintBakRow           : Integer             = 0;

type
  TTempUIButton = Class(TObject)
  public
    class procedure CreateSubModulesFormDialog(const mmItem: TMenuItem; ilMainMenu: TImageList);
    class procedure OnParentModuleButtonClick(Sender: TObject);
    class procedure OnSubModuleButtonClick(Sender: TObject);
  end;

procedure FreeUIButtonResource(tlbMenu: TToolBar);
var
  I     : Integer;
  tbTemp: TToolButton;
begin
  if Assigned(FExitParentToolButton) then
  begin
    FExitParentToolButton.Free;
    FExitParentToolButton := nil;
  end;

  for I := tlbMenu.ButtonCount - 1 downto 0 do
  begin
    tbTemp := tlbMenu.Buttons[I];
    tbTemp.Free;
  end;
end;

procedure GetSubModuleButtonPanel(var pnl: TPanel);
var
  I: Integer;
begin
  for I := 0 to FpnlModuleDialog.ControlCount - 1 do
  begin
    if FpnlModuleDialog.Controls[I] is TPanel then
    begin
      pnl := TPanel(FpnlModuleDialog.Controls[I]);
      Break;
    end;
  end;
end;

class procedure TTempUIButton.OnSubModuleButtonClick(Sender: TObject);
var
  tb      : TToolButton;
  intIndex: Integer;
  I, J    : Integer;
  pMenu   : TMenuItem;
begin
  tb       := TToolButton(Sender);
  intIndex := tb.tag;
  for I    := 0 to FmmMain.Items.Count - 1 do
  begin
    pMenu := FmmMain.Items.Items[I];
    for J := 0 to pMenu.Count - 1 do
    begin
      if pMenu.Items[J].tag = intIndex then
      begin
        pMenu.Items[J].Click;
        Exit;
      end;
    end;
  end;
end;

{ 创建显示所有子模块对话框窗体 }
class procedure TTempUIButton.CreateSubModulesFormDialog(const mmItem: TMenuItem; ilMainMenu: TImageList);
const
  c_intCols         = 5;
  c_intButtonWidth  = 128;
  c_intButtonHeight = 64;
  c_intMiniTop      = 2;
  c_intMiniLeft     = 2;
  c_intHorSpace     = 2;
  c_intVerSpace     = 2;
var
  arrSB               : array of TSpeedButton;
  I, Count            : Integer;
  pnlModuleDialogTitle: TPanel;
begin
  GetSubModuleButtonPanel(pnlModuleDialogTitle);

  { 释放先前创建的按钮 }
  Count := FpnlModuleDialog.ComponentCount;
  if Count > 0 then
  begin
    for I := Count - 1 downto 0 do
    begin
      if FpnlModuleDialog.Components[I] is TSpeedButton then
      begin
        TSpeedButton(FpnlModuleDialog.Components[I]).Free;
      end;
    end;
  end;

  { 创建新的子模块按钮 }
  SetLength(arrSB, mmItem.Count);
  for I := 0 to mmItem.Count - 1 do
  begin
    arrSB[I]            := TSpeedButton.Create(FpnlModuleDialog);
    arrSB[I].Parent     := FpnlModuleDialog;
    arrSB[I].Caption    := mmItem.Items[I].Caption;
    arrSB[I].Width      := c_intButtonWidth;
    arrSB[I].Height     := c_intButtonHeight;
    arrSB[I].GroupIndex := 1;
    arrSB[I].Flat       := True;
    arrSB[I].Top        := pnlModuleDialogTitle.Height + c_intMiniTop + (c_intCols + c_intButtonHeight + c_intVerSpace) * (I div c_intCols);
    arrSB[I].Left       := c_intMiniLeft + (c_intButtonWidth + c_intHorSpace) * (I mod c_intCols);
    arrSB[I].tag        := mmItem.Items[I].tag;
    arrSB[I].OnClick    := OnSubModuleButtonClick;
    ilMainMenu.GetBitmap(mmItem.Items[I].ImageIndex, arrSB[I].Glyph);
  end;

  pnlModuleDialogTitle.Caption                              := mmItem.Caption;
  FpnlModuleDialog.Left                                     := (FpnlModuleDialog.Parent.Width - FpnlModuleDialog.Width) div 2;
  FpnlModuleDialog.Top                                      := (FpnlModuleDialog.Parent.Height - FpnlModuleDialog.Height) div 2;
  FpnlModuleDialog.Visible                                  := True;
  TTabSheet(FpnlModuleDialog.Parent).PageControl.ActivePage := TTabSheet(FpnlModuleDialog.Parent);
end;

class procedure TTempUIButton.OnParentModuleButtonClick(Sender: TObject);
var
  tempTB    : TToolButton;
  I         : Integer;
  tlbPModule: TToolBar;
begin
  FFreeDllForm;
  tempTB     := TToolButton(Sender);
  tlbPModule := TToolBar(TToolButton(Sender).Parent);

  if tempTB.Name = 'ExitProgram' then
  begin
    if MessageBox(Application.MainForm.Handle, '你确定要退出管理系统吗？', c_strMsgTitle, MB_YESNO OR MB_ICONQUESTION) = idYes then
    begin
      FreeUIButtonResource(tlbPModule);
      PostMessage(Application.MainForm.Handle, WM_CLOSE, 0, 0);
    end;

    Exit;
  end;

  for I := 0 to tlbPModule.ButtonCount - 1 do
  begin
    tlbPModule.Buttons[I].Down := False;
  end;
  TToolButton(Sender).Down := True;

  CreateSubModulesFormDialog(FmmMain.Items.Items[tempTB.ImageIndex], FilMainMenu);
end;

{ 按钮风格 UI }
procedure CreateUIType_Button(mmMain: TMainMenu; tlbMenu: TToolBar; ilMainMenu, ilPModule: TImageList; pnlButton: TPanel; pgcAll: TPageControl; FreeDllForm: TCallFunc);
var
  I              : Integer;
  strIconFilePath: String;
  strIconFileName: String;
  icoPModule     : TIcon;
  tmpTB          : TToolButton;
begin
  FFreeDllForm     := FreeDllForm;
  FmmMain          := mmMain;
  FilMainMenu      := ilMainMenu;
  FpnlModuleDialog := pnlButton;

  FreeUIButtonResource(tlbMenu);
  ilPModule.Clear;
  pnlButton.Visible := False;

  { 获取所有父模块图标 }
  for I := 0 to mmMain.Items.Count - 1 do
  begin
    with TIniFile.Create(ChangeFileExt(ParamStr(0), '.ini')) do
    begin
      strIconFilePath := mmMain.Items.Items[I].Caption + '_ICON';
      strIconFileName := ExtractFilePath(ParamStr(0)) + 'plugins\icon\' + ReadString(c_strIniModuleSection, strIconFilePath, '');
      Free;
    end;

    if FileExists(strIconFileName) then
    begin
      icoPModule := TIcon.Create;
      try
        icoPModule.LoadFromFile(strIconFileName);
        ilPModule.AddIcon(icoPModule);
      finally
        icoPModule.Free;
      end;
    end;
  end;

  icoPModule := TIcon.Create;
  try
    icoPModule.LoadFromResourceName(hInstance, 'QUITBUTTONICON');
    ilPModule.AddIcon(icoPModule);
  finally
    icoPModule.Free;
  end;

  FExitParentToolButton            := TToolButton.Create(tlbMenu);
  FExitParentToolButton.Parent     := tlbMenu;
  FExitParentToolButton.Caption    := '退出系统';
  FExitParentToolButton.Name       := 'ExitProgram';
  FExitParentToolButton.ImageIndex := ilPModule.Count - 1;
  FExitParentToolButton.OnClick    := TTempUIButton.OnParentModuleButtonClick;

  for I := mmMain.Items.Count - 1 downto 0 do
  begin
    tmpTB            := TToolButton.Create(tlbMenu);
    tmpTB.Parent     := tlbMenu;
    tmpTB.Caption    := mmMain.Items.Items[I].Caption;
    tmpTB.ImageIndex := I;
    tmpTB.tag        := I;
    tmpTB.OnClick    := TTempUIButton.OnParentModuleButtonClick;
  end;

  for I := 0 to tlbMenu.ButtonCount - 1 do
  begin
    tlbMenu.Buttons[I].Down := False;
  end;

  tlbMenu.Images         := ilPModule;
  tlbMenu.Height         := 58;
  tlbMenu.Parent.Visible := True;
  pgcAll.ActivePageIndex := 1;
end;

type
  TTempUIList = class(TObject)
    class procedure CateModuleExpand(Sender: TObject);
    class procedure OnMenuItemClick(Sender: TObject);
  end;

class procedure TTempUIList.CateModuleExpand(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to FctgrypnlgrpModule.Panels.Count - 1 do
  begin
    if TCategoryPanel(FctgrypnlgrpModule.Panels.Items[I]).tag <> TCategoryPanel(Sender).tag then
    begin
      TCategoryPanel(FctgrypnlgrpModule.Panels.Items[I]).Collapse;
    end;
  end;
end;

class procedure TTempUIList.OnMenuItemClick(Sender: TObject);
var
  btn     : TSpeedButton;
  intIndex: Integer;
  I, J    : Integer;
  pMenu   : TMenuItem;
begin
  btn      := TSpeedButton(Sender);
  intIndex := btn.tag;
  for I    := 0 to FmmMain.Items.Count - 1 do
  begin
    pMenu := FmmMain.Items.Items[I];
    for J := 0 to pMenu.Count - 1 do
    begin
      if pMenu.Items[J].tag = intIndex then
      begin
        pMenu.Items[J].Click;
        Exit;
      end;
    end;
  end;
end;

procedure CreateSubMoudleTree(pnl: TCategoryPanel; mmItem: TMenuItem; ilMainMenu: TImageList);
var
  I  : Integer;
  btn: TSpeedButton;
begin
  for I := 0 to mmItem.Count - 1 do
  begin
    btn := TSpeedButton.Create(pnl);
    begin
      btn.Parent     := pnl;
      btn.Height     := 40;
      btn.Align      := altop;
      btn.Flat       := True;
      btn.GroupIndex := 1;
      btn.tag        := mmItem.Items[I].tag;
      btn.Caption    := AlignStringWidth(mmItem.Items[I].Caption, btn.Font, 80);
      ilMainMenu.GetBitmap(mmItem.Items[I].ImageIndex, btn.Glyph);
      btn.OnClick := TTempUIList.OnMenuItemClick;
    end;
  end;
end;

procedure FreePanlSubModuleButton(ctgrypnlgrpModule: TCategoryPanelGroup);
var
  I, J: Integer;
  pnl : TCategoryPanel;
begin
  if ctgrypnlgrpModule.Panels.Count = 0 then
    Exit;

  for I := 0 to ctgrypnlgrpModule.Panels.Count - 1 do
  begin
    pnl := ctgrypnlgrpModule.Panels[I];
    if pnl.ComponentCount > 0 then
    begin
      for J := pnl.ComponentCount - 1 downto 0 do
      begin
        if pnl.Components[J] is TSpeedButton then
        begin
          TSpeedButton(pnl.Components[J]).Free;
        end;
      end;
    end;
  end;
end;

procedure FreeCatePanelGroup(ctgrypnlgrpModule: TCategoryPanelGroup);
var
  I: Integer;
begin
  if ctgrypnlgrpModule.Panels.Count = 0 then
    Exit;

  for I := ctgrypnlgrpModule.Panels.Count - 1 downto 0 do
  begin
    TCategoryPanel(ctgrypnlgrpModule.Panels[I]).Free;
  end;
end;

{ 列表风格 UI }
procedure CreateUIType_List(ctgrypnlgrpModule: TCategoryPanelGroup; mmMain: TMainMenu; tlbMenu: TToolBar; ilMainMenu: TImageList; pgcAll: TPageControl);
var
  I  : Integer;
  pnl: TCategoryPanel;
begin
  FctgrypnlgrpModule     := ctgrypnlgrpModule;
  FmmMain                := mmMain;
  tlbMenu.Parent.Visible := False;

  FreePanlSubModuleButton(ctgrypnlgrpModule);
  FreeCatePanelGroup(ctgrypnlgrpModule);

  for I := 0 to mmMain.Items.Count - 1 do
  begin
    pnl            := TCategoryPanel.Create(ctgrypnlgrpModule);
    pnl.Height     := 20 + (40 + 5) * mmMain.Items.Items[I].Count;
    pnl.PanelGroup := ctgrypnlgrpModule;
    pnl.Caption    := mmMain.Items.Items[I].Caption;
    CreateSubMoudleTree(pnl, mmMain.Items.Items[I], ilMainMenu);
    if I = 0 then
      pnl.Expand
    else
      pnl.Collapse;
    pnl.tag      := I;
    pnl.OnExpand := TTempUIList.CateModuleExpand;
  end;

  if ctgrypnlgrpModule.Panels.Count > 0 then
    TCategoryPanel(ctgrypnlgrpModule.Panels[0]).Expand;

  pgcAll.ActivePageIndex := 2;
end;

type
  TTempUICenter = class(TObject)
  public
    class procedure OnSubModuleMouseEnter(Sender: TObject);
    class procedure OnSubModuleMouseLeave(Sender: TObject);
    class procedure OnSubModuleListClick(Sender: TObject);
  end;

class procedure TTempUICenter.OnSubModuleMouseEnter(Sender: TObject);
begin
  TLabel(Sender).Font.Color := RGB(0, 0, 255);
  TLabel(Sender).Font.Style := TLabel(Sender).Font.Style + [fsUnderline];
end;

class procedure TTempUICenter.OnSubModuleMouseLeave(Sender: TObject);
begin
  TLabel(Sender).Font.Color := RGB(51, 153, 255);
  TLabel(Sender).Font.Style := TLabel(Sender).Font.Style - [fsUnderline];
end;

class procedure TTempUICenter.OnSubModuleListClick(Sender: TObject);
var
  intTag: Integer;
  I, J  : Integer;
  mmItem: TMenuItem;
begin
  intTag := TLabel(Sender).tag;
  for I  := 0 to FmmMain.Items.Count - 1 do
  begin
    for J := 0 to FmmMain.Items.Items[I].Count - 1 do
    begin
      if FmmMain.Items.Items[I].Items[J].tag = intTag then
      begin
        mmItem := FmmMain.Items.Items[I].Items[J];
        mmItem.Click;
        Break;
      end;
    end;
  end;
end;

procedure FreeListViewSubModule(pgcAll: TPageControl);
var
  I: Integer;
begin
  if not Assigned(pgcAll.ActivePage) then
    Exit;

  for I := pgcAll.ActivePage.ComponentCount - 1 downto 0 do
  begin
    if pgcAll.ActivePage.Components[I] is TLabel then
    begin
      TLabel(pgcAll.ActivePage.Components[I]).Free;
    end
    else if pgcAll.ActivePage.Components[I] is TImage then
    begin
      if TImage(pgcAll.ActivePage.Components[I]).Name = '' then
      begin
        TImage(pgcAll.ActivePage.Components[I]).Free;
      end;
    end;
  end;
end;

{ 中心风格 UI }
procedure CreateUIType_Center(mmMain: TMainMenu; tlbMenu: TToolBar; ilMainMenu: TImageList; pgcAll: TPageControl; var bChangeUI: Boolean);
const
  c_intPModuleFontSize = 13;
  c_intSModuleFontSize = 11;
var
  I                     : Integer;
  arrParentModuleLabel  : array of TLabel;
  arrParentModuleImage  : array of TImage;
  arrSubModuleLabel     : array of array of TLabel;
  intRow                : Integer;
  strPModuleIconFileName: string;
  strPModuleIconFilePath: string;
  J                     : Integer;
  bMaxForm              : Boolean;
begin
  if bChangeUI then
  begin
    FintBakRow := -1;
    bChangeUI  := False;
  end;

  FmmMain  := mmMain;
  bMaxForm := Application.MainForm.WindowState = TWindowState.wsMaximized;
  intRow   := Ifthen(bMaxForm, 5, 3);
  if FintBakRow = intRow then
    Exit;

  { 销毁分栏式界面 }
  FreeListViewSubModule(pgcAll);
  FintBakRow := intRow;

  tlbMenu.Parent.Visible := False;
  pgcAll.ActivePageIndex := 3;
  SetLength(arrParentModuleLabel, mmMain.Items.Count);
  SetLength(arrParentModuleImage, mmMain.Items.Count);
  SetLength(arrSubModuleLabel, mmMain.Items.Count);
  for I := 0 to mmMain.Items.Count - 1 do
  begin
    SetLength(arrSubModuleLabel[I], mmMain.Items[I].Count);
  end;

  for I := 0 to mmMain.Items.Count - 1 do
  begin
    { 创建父模块文本 }
    arrParentModuleLabel[I]            := TLabel.Create(pgcAll.ActivePage);
    arrParentModuleLabel[I].Parent     := pgcAll.ActivePage;
    arrParentModuleLabel[I].Caption    := mmMain.Items[I].Caption;
    arrParentModuleLabel[I].Font.Name  := '宋体';
    arrParentModuleLabel[I].Font.Size  := c_intPModuleFontSize;
    arrParentModuleLabel[I].Font.Style := [fsBold];
    arrParentModuleLabel[I].Font.Color := RGB(0, 174, 29);
    arrParentModuleLabel[I].Left       := 40 + 400 * (I mod intRow);
    arrParentModuleLabel[I].Top        := GetMaxInstance(mmMain) * (I div intRow);

    { 创建父模块图标 }
    arrParentModuleImage[I]         := TImage.Create(pgcAll.ActivePage);
    arrParentModuleImage[I].Parent  := pgcAll.ActivePage;
    arrParentModuleImage[I].Height  := 32;
    arrParentModuleImage[I].Width   := 32;
    arrParentModuleImage[I].Stretch := True;
    arrParentModuleImage[I].Left    := arrParentModuleLabel[I].Left - 40;
    arrParentModuleImage[I].Top     := arrParentModuleLabel[I].Top;
    with TIniFile.Create(ChangeFileExt(ParamStr(0), '.ini')) do
    begin
      strPModuleIconFilePath := ReadString(c_strIniModuleSection, arrParentModuleLabel[I].Caption + '_ICON', '');
      strPModuleIconFileName := ExtractFilePath(ParamStr(0)) + 'plugins\icon\' + strPModuleIconFilePath;
      if FileExists(strPModuleIconFileName) then
        arrParentModuleImage[I].Picture.LoadFromFile(strPModuleIconFileName);
      Free;
    end;

    { 创建子模块文本 }
    for J := 0 to Length(arrSubModuleLabel[I]) - 1 do
    begin
      arrSubModuleLabel[I, J]            := TLabel.Create(pgcAll.ActivePage);
      arrSubModuleLabel[I, J].Parent     := pgcAll.ActivePage;
      arrSubModuleLabel[I, J].Caption    := mmMain.Items[I].Items[J].Caption;
      arrSubModuleLabel[I, J].Font.Name  := '宋体';
      arrSubModuleLabel[I, J].Font.Size  := c_intSModuleFontSize;
      arrSubModuleLabel[I, J].Font.Style := [fsBold];
      arrSubModuleLabel[I, J].Font.Color := RGB(51, 153, 255);
      arrSubModuleLabel[I, J].Cursor     := crHandPoint;
      if J mod 3 = 0 then
        arrSubModuleLabel[I, J].Left := arrParentModuleLabel[I].Left + 2
      else
        arrSubModuleLabel[I, J].Left       := arrSubModuleLabel[I, J - 1].Left + arrSubModuleLabel[I, J - 1].Width + 10;
      arrSubModuleLabel[I, J].Top          := arrParentModuleLabel[I].Top + GetLabelHeight('宋体', c_intPModuleFontSize) + c_intBetweenVerticalDistance + (GetLabelHeight('宋体', c_intSModuleFontSize) + c_intBetweenVerticalDistance) * (J div 3);
      arrSubModuleLabel[I, J].tag          := mmMain.Items[I].Items[J].tag;
      arrSubModuleLabel[I, J].OnMouseEnter := TTempUICenter.OnSubModuleMouseEnter;
      arrSubModuleLabel[I, J].OnMouseLeave := TTempUICenter.OnSubModuleMouseLeave;
      arrSubModuleLabel[I, J].OnClick      := TTempUICenter.OnSubModuleListClick;
    end;
  end;
end;

end.
