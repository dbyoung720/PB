unit untSysSearch;
{$WARN UNIT_PLATFORM OFF}

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.StrUtils, System.Variants, System.Classes, System.Win.Registry, System.IniFiles, System.Types, System.IOUtils,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.FileCtrl, Vcl.Clipbrd, Vcl.StdCtrls, uCommon;

type
  TfrmSysSearch = class(TForm)
    lst1: TListBox;
    btnSysSearchAdd: TButton;
    btnSysSearchModify: TButton;
    btnSysSearchUp: TButton;
    btnSysSearchDown: TButton;
    btnSysSearchUpTop: TButton;
    btnSysSearchDownBottom: TButton;
    btnSysSearchBackup: TButton;
    btnSysSearchRestore: TButton;
    btnSysSearchDel: TButton;
    btnInputSysSearch: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnSysSearchAddClick(Sender: TObject);
    procedure btnSysSearchDelClick(Sender: TObject);
    procedure btnSysSearchModifyClick(Sender: TObject);
    procedure btnSysSearchUpClick(Sender: TObject);
    procedure btnSysSearchDownClick(Sender: TObject);
    procedure btnSysSearchUpTopClick(Sender: TObject);
    procedure btnSysSearchDownBottomClick(Sender: TObject);
    procedure btnSysSearchBackupClick(Sender: TObject);
    procedure btnSysSearchRestoreClick(Sender: TObject);
    procedure btnInputSysSearchClick(Sender: TObject);
  private
    { private declarations }
  public
    { Public declarations }
  end;

procedure db_ShowDllForm_Plugins(var frm: TFormClass; var strParentModuleName, strSubModuleName: PAnsiChar); stdcall;

implementation

{$R *.dfm}

procedure db_ShowDllForm_Plugins(var frm: TFormClass; var strParentModuleName, strSubModuleName: PAnsiChar); stdcall;
begin
  frm                     := TfrmSysSearch;
  strParentModuleName     := '系统管理';
  strSubModuleName        := '系统搜索路径';
  Application.Handle      := GetMainFormApplication.Handle;
  Application.Icon.Handle := GetDllModuleIconHandle(String(strParentModuleName), string(strSubModuleName));
end;

function GetSysSearchPath: TStringDynArray;
begin
  with TRegistry.Create do
  begin
    RootKey := HKEY_LOCAL_MACHINE;
    OpenKey('SYSTEM\CurrentControlSet\Control\Session Manager\Environment', False);
    Result := SplitString(ReadString('Path'), ';');
    Free;
  end;
end;

procedure ModifySysSearchPath(const strsList: TStrings);
var
  strSearchPath: String;
  III          : Integer;
  rv           : DWORD_PTR;
begin
  strSearchPath := '';
  for III       := 0 to strsList.Count - 1 do
  begin
    if (Trim(strsList.Strings[III]) <> '') and (strsList.Strings[III] <> ';') then
    begin
      // if SysUtils.DirectoryExists(strsList.Strings[III]) then
      // begin
      strSearchPath := strSearchPath + ';' + strsList.Strings[III];
      // end
      // else
      // begin
      // ShowMessage(Format('%s 文件夹不存在', [strsList.Strings[III]]));
      // end;
    end;
  end;
  strSearchPath := RightStr(strSearchPath, Length(strSearchPath) - 1);

  with TRegistry.Create do
  begin
    RootKey := HKEY_LOCAL_MACHINE;
    OpenKey('SYSTEM\CurrentControlSet\Control\Session Manager\Environment', False);
    if (Win32MajorVersion >= 6) and (Win32MinorVersion >= 1) then
      WriteExpandString('Path', strSearchPath)
    else
      WriteString('Path', strSearchPath);

    SystemParametersInfo(SPI_SETCURSORS, 0, nil, SPIF_SENDCHANGE);
    SendMessageTimeout(HWND_BROADCAST, WM_WININICHANGE, $2A, LParam(PChar('Environment')), SMTO_NORMAL or SMTO_ABORTIFHUNG or SMTO_BLOCK, 5000, @rv);

    CloseKey;
    Free;
  end;
end;

procedure TfrmSysSearch.FormCreate(Sender: TObject);
var
  strArr: TStringDynArray;
  III   : Integer;
begin
  strArr  := GetSysSearchPath;
  for III := Low(strArr) to High(strArr) do
  begin
    lst1.Items.Add(strArr[III]);
  end;
end;

{ 添加 }
procedure TfrmSysSearch.btnSysSearchAddClick(Sender: TObject);
var
  strSelectDir   : String;
  hMainForm      : THandle;
  hMainFormObject: TWinControl;
begin
  hMainForm       := GetMainFormHandle;
  hMainFormObject := GetInstanceFromhWnd(hMainForm);
  if not SelectDirectory('请选择一个文件夹：', '', strSelectDir, [sdNewUI], hMainFormObject) then
    Exit;

  lst1.Items.Add(strSelectDir);
  ModifySysSearchPath(lst1.Items);
end;

{ 输入 }
procedure TfrmSysSearch.btnInputSysSearchClick(Sender: TObject);
var
  strNewPath: String;
begin
  strNewPath := Clipboard.AsText;
  if not InputQuery('添加路径：', '名称：', strNewPath) then
    Exit;

  lst1.Selected[lst1.Items.Add(strNewPath)] := True;
  ModifySysSearchPath(lst1.Items);
end;

{ 删除 }
procedure TfrmSysSearch.btnSysSearchDelClick(Sender: TObject);
begin
  if lst1.ItemIndex < 0 then
    Exit;

  lst1.DeleteSelected;
  ModifySysSearchPath(lst1.Items);
end;

{ 修改 }
procedure TfrmSysSearch.btnSysSearchModifyClick(Sender: TObject);
var
  strNewPath: String;
begin
  if lst1.ItemIndex < 0 then
    Exit;

  strNewPath := lst1.Items.Strings[lst1.ItemIndex];
  if not InputQuery('修改路径', '路径：', strNewPath) then
    Exit;

  lst1.Items.Strings[lst1.ItemIndex] := strNewPath;
  ModifySysSearchPath(lst1.Items);
end;

{ 上移 }
procedure TfrmSysSearch.btnSysSearchUpClick(Sender: TObject);
begin
  if lst1.ItemIndex <= 0 then
    Exit;

  lst1.Items.Exchange(lst1.ItemIndex, lst1.ItemIndex - 1);
  ModifySysSearchPath(lst1.Items);
end;

{ 下移 }
procedure TfrmSysSearch.btnSysSearchDownClick(Sender: TObject);
begin
  if lst1.ItemIndex < 0 then
    Exit;

  if lst1.ItemIndex >= lst1.Items.Count - 1 then
    Exit;

  lst1.Items.Exchange(lst1.ItemIndex, lst1.ItemIndex + 1);
  ModifySysSearchPath(lst1.Items);
end;

{ 上移到顶端 }
procedure TfrmSysSearch.btnSysSearchUpTopClick(Sender: TObject);
begin
  if lst1.ItemIndex <= 0 then
    Exit;

  lst1.Items.Move(lst1.ItemIndex, 0);
  ModifySysSearchPath(lst1.Items);
  lst1.Selected[0] := True;
end;

{ 下移到底端 }
procedure TfrmSysSearch.btnSysSearchDownBottomClick(Sender: TObject);
begin
  if lst1.ItemIndex < 0 then
    Exit;

  if lst1.ItemIndex >= lst1.Items.Count - 1 then
    Exit;

  lst1.Items.Move(lst1.ItemIndex, lst1.Items.Count - 1);
  ModifySysSearchPath(lst1.Items);
  lst1.Selected[lst1.Items.Count - 1] := True;
end;

{ 备份 }
procedure TfrmSysSearch.btnSysSearchBackupClick(Sender: TObject);
begin
  with TSaveDialog.Create(nil) do
  begin
    Filter := '系统搜索路径备份文件(*.SSP)|*.SSP';
    if Execute(GetMainFormHandle) then
    begin
      lst1.Items.SaveToFile(FileName + '.SSP');
    end;
    Free;
  end;
end;

{ 还原 }
procedure TfrmSysSearch.btnSysSearchRestoreClick(Sender: TObject);
begin
  with TOpenDialog.Create(nil) do
  begin
    Filter := '系统搜索路径备份文件(*.SSP)|*.SSP';
    if Execute(GetMainFormHandle) then
    begin
      lst1.Items.LoadFromFile(FileName);
      ModifySysSearchPath(lst1.Items);
    end;
    Free;
  end;
end;

end.
