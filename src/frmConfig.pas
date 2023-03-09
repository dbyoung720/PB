unit frmConfig;

interface

uses
  Winapi.Windows, Winapi.ShellAPI, System.SysUtils, System.StrUtils, System.Classes, System.IniFiles, System.Win.Registry, Data.Win.ADODB,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtDlgs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.WinXCtrls, Vcl.Buttons, Vcl.ComCtrls, uBaseForm;

type
  TfrmConfig = class(TForm)
    lbl2: TLabel;
    lbl3: TLabel;
    lbl1: TLabel;
    btnDatabaseConfig: TSpeedButton;
    grpUI: TGroupBox;
    lblTitle: TLabel;
    edtTitle: TEdit;
    chkTopForm: TCheckBox;
    chkCloseMini: TCheckBox;
    chkAutorun: TCheckBox;
    chkOnlyOneInstance: TCheckBox;
    btnSave: TButton;
    btnCancel: TButton;
    rgShowStyle: TRadioGroup;
    grpModuleSort: TGroupBox;
    imgPModuleIcon: TImage;
    imgSModuleIcon: TImage;
    lblPModule: TLabel;
    lblSModule: TLabel;
    lstParentModule: TListBox;
    lstSubModule: TListBox;
    btnParentUp: TButton;
    btnParentDown: TButton;
    btnSubUp: TButton;
    btnSubDown: TButton;
    btnSubModuleIcon: TButton;
    chkGray: TCheckBox;
    btnPModuleIcon: TButton;
    chkShowCloseButton: TCheckBox;
    chkFullScreen: TCheckBox;
    OpenPictureDialog1: TOpenPictureDialog;
    btnAddEXE: TButton;
    chkLoadSpeed: TCheckBox;
    procedure btnCancelClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnDatabaseConfigClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure lstParentModuleClick(Sender: TObject);
    procedure btnParentUpClick(Sender: TObject);
    procedure btnParentDownClick(Sender: TObject);
    procedure btnSubUpClick(Sender: TObject);
    procedure btnSubDownClick(Sender: TObject);
    procedure btnAddEXEClick(Sender: TObject);
    procedure lstSubModuleClick(Sender: TObject);
    procedure imgPModuleIconClick(Sender: TObject);
    procedure imgSModuleIconClick(Sender: TObject);
    procedure rgShowStyleClick(Sender: TObject);
    procedure chkLoadSpeedClick(Sender: TObject);
  private
    FbCreate     : Boolean;
    FmemIni      : TMemIniFile;
    FlstModuleAll: THashedStringList;
    FilMainMenu  : TImageList;
    FbResult     : Boolean;
    procedure ReadConfigFillUI;
    procedure SaveConfig;
    procedure FillSubModule(lstModule: TListBox; const strModuleName: string);
    function CheckExeFile(const strPModuleName, strSModuleName: string; var strExeFileName: String): Boolean;
  public
    { Public declarations }
  end;

function ShowConfigForm(var lstModuleAll: THashedStringList; const ilMainMenu: TImageList): Boolean;

implementation

uses uImgListEx, frmAddEXE;

{$R *.dfm}

const
  c_strTitle            = 'PBox 基于 DLL 窗口的模块化开发平台 v5.0';
  c_strIniUISection     = 'UI';
  c_strIniModuleSection = 'Module';

function ShowConfigForm(var lstModuleAll: THashedStringList; const ilMainMenu: TImageList): Boolean;
begin
  with TfrmConfig.Create(nil) do
  begin
    FbCreate      := True;
    FbResult      := False;
    FlstModuleAll := lstModuleAll;
    FilMainMenu   := ilMainMenu;
    ReadConfigFillUI;
    Position := poScreenCenter;
    ShowModal;
    Result := FbResult;
    Free;
  end;
end;

procedure ShowDBConfigForm(memIni: TMemIniFile; frm: TForm);
var
  strDBEngineDllFileName: String;
  hDLL                  : HMODULE;
  pFunc                 : procedure(memIni: TMemIniFile; frm: TForm); stdcall;
begin
  strDBEngineDllFileName := ExtractFilePath(ParamStr(0)) + 'plugins\dbe.dll';
  if not FileExists(strDBEngineDllFileName) then
    Exit;

  hDLL := LoadLibrary(PChar(strDBEngineDllFileName));
  if hDLL = INVALID_HANDLE_VALUE then
    Exit;

  try
    pFunc := GetProcAddress(hDLL, 'ShowDBConfigForm');
    if @pFunc = nil then
      Exit;

    pFunc(memIni, frm);
  finally
    FreeLibrary(hDLL);
  end;
end;

procedure TfrmConfig.btnDatabaseConfigClick(Sender: TObject);
begin
  ShowDBConfigForm(FmemIni, Self);
end;

{ 模块上移 }
procedure TfrmConfig.btnParentUpClick(Sender: TObject);
var
  intSelectedIndex: Integer;
  intPirorIndex   : Integer;
  strBackup       : String;
begin
  intSelectedIndex := lstParentModule.ItemIndex;
  intPirorIndex    := intSelectedIndex - 1;
  if intPirorIndex >= 0 then
  begin
    strBackup                                       := lstParentModule.Items.Strings[intPirorIndex];
    lstParentModule.Items.Strings[intPirorIndex]    := lstParentModule.Items.Strings[intSelectedIndex];
    lstParentModule.Items.Strings[intSelectedIndex] := strBackup;
    lstParentModule.Selected[intPirorIndex]         := True;
  end;
end;

{ 模块下移 }
procedure TfrmConfig.btnParentDownClick(Sender: TObject);
var
  intSelectedIndex: Integer;
  intNextIndex    : Integer;
  strBackup       : String;
begin
  intSelectedIndex := lstParentModule.ItemIndex;
  intNextIndex     := intSelectedIndex + 1;
  if intNextIndex < lstParentModule.Count then
  begin
    strBackup                                       := lstParentModule.Items.Strings[intNextIndex];
    lstParentModule.Items.Strings[intNextIndex]     := lstParentModule.Items.Strings[intSelectedIndex];
    lstParentModule.Items.Strings[intSelectedIndex] := strBackup;
    lstParentModule.Selected[intNextIndex]          := True;
  end;
end;

{ 添加 EXE }
procedure TfrmConfig.btnAddEXEClick(Sender: TObject);
var
  strPModuleName, strSModuleName, strFormClassName, strFormTitleName, strExeFileName: string;
begin
  if lstParentModule.ItemIndex = -1 then
    strPModuleName := ''
  else
    strPModuleName := lstParentModule.Items.Strings[lstParentModule.ItemIndex];

  if ShowAddEXEForm(strPModuleName, strSModuleName, strFormClassName, strFormTitleName, strExeFileName) then
  begin
    FmemIni.WriteString('EXE', strExeFileName, Format('%s;%s;%s;%s', [strPModuleName, strSModuleName, strFormClassName, strFormTitleName]));
    lstSubModule.ItemIndex := lstSubModule.Items.Add(strSModuleName);
    FlstModuleAll.Add(Format('%s=%s;%s;%s;%s;', [strExeFileName, strPModuleName, strSModuleName, strFormClassName, strFormTitleName]));
    lstSubModule.OnClick(nil);
  end;
end;

procedure TfrmConfig.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure EnableAutoRun(const bAutoRun: Boolean = False);
begin
  with TRegistry.Create do
  begin
    RootKey := HKEY_LOCAL_MACHINE;
    OpenKey('SOFTWARE\Microsoft\Windows\CurrentVersion\Run', True);
    if not bAutoRun then
      DeleteValue('PBox')
    else
      WriteString('PBox', ParamStr(0));
    Free;
  end;
end;

procedure TfrmConfig.SaveConfig;
begin
  FmemIni.WriteString(c_strIniUISection, 'Title', edtTitle.Text);
  FmemIni.WriteBool(c_strIniUISection, 'OnTop', chkTopForm.Checked);
  FmemIni.WriteBool(c_strIniUISection, 'MAXSIZE', chkFullScreen.Checked);
  FmemIni.WriteBool(c_strIniUISection, 'CloseMini', chkCloseMini.Checked);
  FmemIni.WriteBool(c_strIniUISection, 'AutoRun', chkAutorun.Checked);
  FmemIni.WriteBool(c_strIniUISection, 'OnlyOneInstance', chkOnlyOneInstance.Checked);
  FmemIni.WriteInteger(c_strIniUISection, 'ShowStyle', rgShowStyle.ItemIndex);
  FmemIni.WriteBool(c_strIniUISection, 'ShowCloseButton', chkShowCloseButton.Checked);
  FmemIni.WriteBool(c_strIniUISection, 'LoadSpeed', chkLoadSpeed.Checked);

  EnableAutoRun(chkAutorun.Checked);

  lstParentModule.Items.Delimiter := ';';
  FmemIni.WriteString(c_strIniModuleSection, 'Order', lstParentModule.Items.DelimitedText);
end;

procedure TfrmConfig.ReadConfigFillUI;
var
  I             : Integer;
  strPModuleName: String;
begin
  chkLoadSpeed.Enabled       := False;
  edtTitle.Text              := FmemIni.ReadString(c_strIniUISection, 'Title', c_strTitle);
  chkTopForm.Checked         := FmemIni.ReadBool(c_strIniUISection, 'OnTop', False);
  chkFullScreen.Checked      := FmemIni.ReadBool(c_strIniUISection, 'MAXSIZE', False);
  chkCloseMini.Checked       := FmemIni.ReadBool(c_strIniUISection, 'CloseMini', False);
  chkAutorun.Checked         := FmemIni.ReadBool(c_strIniUISection, 'AutoRun', False);
  chkOnlyOneInstance.Checked := FmemIni.ReadBool(c_strIniUISection, 'OnlyOneInstance', True);
  chkLoadSpeed.Checked       := FmemIni.ReadBool(c_strIniUISection, 'LoadSpeed', False);
  rgShowStyle.ItemIndex      := FmemIni.ReadInteger(c_strIniUISection, 'ShowStyle', 0);
  chkShowCloseButton.Checked := FmemIni.ReadBool(c_strIniUISection, 'ShowCloseButton', True);
  chkLoadSpeed.Enabled       := True;

  { 模块列表 }
  for I := 0 to FlstModuleAll.Count - 1 do
  begin
    strPModuleName := FlstModuleAll.ValueFromIndex[I].Split([';'])[0];
    if lstParentModule.Items.IndexOf(strPModuleName) = -1 then
      lstParentModule.Items.Add(strPModuleName);
  end;
end;

procedure TfrmConfig.rgShowStyleClick(Sender: TObject);
begin
  chkShowCloseButton.Enabled := rgShowStyle.ItemIndex <> 2;
  if rgShowStyle.ItemIndex = 2 then
  begin
    chkShowCloseButton.Checked := True;
  end;
end;

procedure TfrmConfig.btnSaveClick(Sender: TObject);
begin
  FbResult := True;
  SaveConfig;
  FmemIni.UpdateFile;

  { 排序模块 }
  SortModuleList(FlstModuleAll);
  Close;
end;

{ 子模块上移 }
procedure TfrmConfig.btnSubUpClick(Sender: TObject);
var
  intSelectedIndex: Integer;
  intPirorIndex   : Integer;
  strBackup       : String;
begin
  intSelectedIndex := lstSubModule.ItemIndex;
  intPirorIndex    := intSelectedIndex - 1;
  if intPirorIndex >= 0 then
  begin
    strBackup                                    := lstSubModule.Items.Strings[intPirorIndex];
    lstSubModule.Items.Strings[intPirorIndex]    := lstSubModule.Items.Strings[intSelectedIndex];
    lstSubModule.Items.Strings[intSelectedIndex] := strBackup;
    lstSubModule.Selected[intPirorIndex]         := True;

    lstSubModule.Items.Delimiter := ';';
    FmemIni.WriteString(c_strIniModuleSection, lstParentModule.Items.Strings[lstParentModule.ItemIndex], lstSubModule.Items.DelimitedText);
  end;
end;

{ 子模块下移 }
procedure TfrmConfig.btnSubDownClick(Sender: TObject);
var
  intSelectedIndex: Integer;
  intNextIndex    : Integer;
  strBackup       : String;
begin
  intSelectedIndex := lstSubModule.ItemIndex;
  intNextIndex     := intSelectedIndex + 1;
  if intNextIndex < lstSubModule.Count then
  begin
    strBackup                                    := lstSubModule.Items.Strings[intNextIndex];
    lstSubModule.Items.Strings[intNextIndex]     := lstSubModule.Items.Strings[intSelectedIndex];
    lstSubModule.Items.Strings[intSelectedIndex] := strBackup;
    lstSubModule.Selected[intNextIndex]          := True;

    lstSubModule.Items.Delimiter := ';';
    FmemIni.WriteString(c_strIniModuleSection, lstParentModule.Items.Strings[lstParentModule.ItemIndex], lstSubModule.Items.DelimitedText);
  end;
end;

procedure TfrmConfig.FormCreate(Sender: TObject);
begin
  FmemIni := TMemIniFile.Create(ChangeFileExt(ParamStr(0), '.ini'));
end;

procedure TfrmConfig.FormDestroy(Sender: TObject);
begin
  FmemIni.Free;
end;

{ 设置父模块显示图标 }
procedure TfrmConfig.imgPModuleIconClick(Sender: TObject);
var
  strIconFilePath: String;
begin
  if lstParentModule.ItemIndex < 0 then
  begin
    MessageBox(Application.MainForm.Handle, '必须从父模块列表中选择一个模块', '系统提示：', MB_OK OR MB_ICONINFORMATION);
    lstParentModule.SetFocus;
    Exit;
  end;

  with TOpenDialog.Create(nil) do
  begin
    Filter := '图标文件(*.ico)|*.ico';
    if Execute(Handle) then
    begin
      with TPicture.Create do
      begin
        LoadFromFile(FileName);
        strIconFilePath := ExtractFilePath(ParamStr(0)) + 'plugins\Icon\' + ExtractFileName(FileName);
        if not DirectoryExists(ExtractFilePath(strIconFilePath)) then
          ForceDirectories(ExtractFilePath(strIconFilePath));
        CopyFile(PChar(FileName), PChar(strIconFilePath), False);
        FmemIni.WriteString(c_strIniModuleSection, lstParentModule.Items.Strings[lstParentModule.ItemIndex] + '_ICON', ExtractFileName(FileName));
        imgPModuleIcon.Picture.LoadFromFile(strIconFilePath);
        Free;
      end;
    end;
    Free;
  end;
end;

{ 设置子模块显示图标 }
procedure TfrmConfig.imgSModuleIconClick(Sender: TObject);
var
  strIconFilePath               : String;
  strPModuleName, strSModuleName: String;
begin
  if lstParentModule.ItemIndex < 0 then
  begin
    MessageBox(Application.MainForm.Handle, '必须从父模块列表中选择一个模块', '系统提示：', MB_OK OR MB_ICONINFORMATION);
    lstParentModule.SetFocus;
    Exit;
  end;

  if lstSubModule.ItemIndex < 0 then
  begin
    MessageBox(Application.MainForm.Handle, '必须从子模块列表中选择一个模块', '系统提示：', MB_OK OR MB_ICONINFORMATION);
    lstSubModule.SetFocus;
    Exit;
  end;

  strPModuleName := lstParentModule.Items.Strings[lstParentModule.ItemIndex];
  strSModuleName := lstSubModule.Items.Strings[lstSubModule.ItemIndex];
  with TOpenDialog.Create(nil) do
  begin
    Filter := '图标文件(*.ico)|*.ico';
    if Execute(Handle) then
    begin
      with TPicture.Create do
      begin
        LoadFromFile(FileName);
        strIconFilePath := ExtractFilePath(ParamStr(0)) + 'plugins\Icon\' + ExtractFileName(FileName);
        if not DirectoryExists(ExtractFilePath(strIconFilePath)) then
          ForceDirectories(ExtractFilePath(strIconFilePath));
        CopyFile(PChar(FileName), PChar(strIconFilePath), False);
        FmemIni.WriteString(c_strIniModuleSection, String(strPModuleName) + '_' + string(strSModuleName) + '_ICON', ExtractFileName(FileName));
        imgSModuleIcon.Picture.LoadFromFile(strIconFilePath);
        Free;
      end;
    end;
    Free;
  end;
end;

procedure TfrmConfig.FillSubModule(lstModule: TListBox; const strModuleName: string);
var
  strPModuleName: string;
  strSModuleName: string;
  I             : Integer;
begin
  { 模块列表 }
  for I := 0 to FlstModuleAll.Count - 1 do
  begin
    strPModuleName := FlstModuleAll.ValueFromIndex[I].Split([';'])[0];
    strSModuleName := FlstModuleAll.ValueFromIndex[I].Split([';'])[1];
    if CompareText(strModuleName, strPModuleName) = 0 then
    begin
      lstModule.Items.Add(strSModuleName);
    end;
  end;
end;

procedure TfrmConfig.lstParentModuleClick(Sender: TObject);
var
  strPModuleName        : string;
  strPModuleIconFileName: String;
begin
  if lstParentModule.ItemIndex < 0 then
    Exit;

  if lstParentModule.SelCount = 0 then
    Exit;

  { 父模块图标 }
  imgPModuleIcon.Picture.Assign(nil);
  imgSModuleIcon.Picture.Assign(nil);
  strPModuleIconFileName := FmemIni.ReadString(c_strIniModuleSection, lstParentModule.Items.Strings[lstParentModule.ItemIndex] + '_ICON', '');
  strPModuleIconFileName := ExtractFilePath(ParamStr(0)) + 'plugins\Icon\' + strPModuleIconFileName;
  if FileExists(strPModuleIconFileName) then
  begin
    with TPicture.Create do
    begin
      LoadFromFile(strPModuleIconFileName);
      imgPModuleIcon.Picture.LoadFromFile(strPModuleIconFileName);
      Free;
    end;
  end;

  { 子模块列表 }
  lstSubModule.Clear;
  strPModuleName := lstParentModule.Items.Strings[lstParentModule.ItemIndex];
  FillSubModule(lstSubModule, strPModuleName);
end;

function TfrmConfig.CheckExeFile(const strPModuleName, strSModuleName: string; var strExeFileName: String): Boolean;
var
  I                  : Integer;
  strParentModuleName: String;
  strSubModuleName   : String;
begin
  Result := False;
  for I  := 0 to FlstModuleAll.Count - 1 do
  begin
    strParentModuleName := FlstModuleAll.ValueFromIndex[I].Split([';'])[0];
    strSubModuleName    := FlstModuleAll.ValueFromIndex[I].Split([';'])[1];
    if (CompareText(strParentModuleName, strPModuleName) = 0) and (CompareText(strSubModuleName, strSModuleName) = 0) then
    begin
      strExeFileName := FlstModuleAll.Names[I];
      Result         := (CompareText('.exe', ExtractFileExt(strExeFileName)) = 0) or (CompareText('.msc', ExtractFileExt(strExeFileName)) = 0);
      Break;
    end;
  end;
end;

procedure TfrmConfig.lstSubModuleClick(Sender: TObject);
var
  strPModuleName, strSModuleName: String;
  strIconFileName               : String;
  strExeFileName                : String;
  IcoExe                        : TIcon;
begin
  if lstParentModule.ItemIndex < 0 then
    Exit;

  if lstSubModule.ItemIndex < 0 then
    Exit;

  imgSModuleIcon.Picture.Assign(nil);
  strPModuleName := lstParentModule.Items.Strings[lstParentModule.ItemIndex];
  strSModuleName := lstSubModule.Items.Strings[lstSubModule.ItemIndex];

  if CheckExeFile(strPModuleName, strSModuleName, strExeFileName) then
  begin
    btnSubModuleIcon.Enabled := False;
    imgSModuleIcon.Enabled   := False;

    if CompareText(ExtractFileExt(strExeFileName), '.exe') = 0 then
    begin
      if ExtractIcon(HInstance, PChar(strExeFileName), $FFFFFFFF) > 0 then
      begin
        IcoExe := TIcon.Create;
        try
          IcoExe.Handle := ExtractIcon(HInstance, PChar(strExeFileName), 0);
          imgSModuleIcon.Picture.Assign(IcoExe);
        finally
          IcoExe.Free;
        end;
      end;
    end;

    if CompareText(ExtractFileExt(strExeFileName), '.msc') = 0 then
    begin
      IcoExe := TIcon.Create;
      try
        LoadIconFromMSCFile(strExeFileName, IcoExe);
        imgSModuleIcon.Picture.Assign(IcoExe);
      finally
        IcoExe.Free;
      end;
    end;
  end
  else
  begin
    btnSubModuleIcon.Enabled := True;
    imgSModuleIcon.Enabled   := True;
    chkGray.Checked          := FmemIni.ReadBool(c_strIniModuleSection, String(strPModuleName) + '_' + string(strSModuleName) + '_HIDE', False);
    strIconFileName          := FmemIni.ReadString(c_strIniModuleSection, strPModuleName + '_' + strSModuleName + '_ICON', '');
    strIconFileName          := ExtractFilePath(ParamStr(0)) + 'plugins\Icon\' + strIconFileName;
    if FileExists(strIconFileName) then
    begin
      imgSModuleIcon.Picture.LoadFromFile(strIconFileName);
    end;
  end;
end;

procedure TfrmConfig.chkLoadSpeedClick(Sender: TObject);
var
  strTemp: String;
begin
  if FbCreate then
  begin
    FbCreate := False;
    Exit;
  end;

  if chkLoadSpeed.Checked then
  begin
    strTemp := GetLoadSpeedFileName_Config;
    FlstModuleAll.SaveToFile(strTemp);

    strTemp := GetLoadSpeedFileName_icolst;
    TImageListEx(FilMainMenu).SaveToFile(GetLoadSpeedFileName_icolst);
  end
  else
  begin
    DeleteFile(GetLoadSpeedFileName_Config);
    DeleteFile(GetLoadSpeedFileName_icolst);
  end;
end;

end.
