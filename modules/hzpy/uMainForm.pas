unit uMainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, StdCtrls, Menus, uScrollBar, uCommon;

type
  TfrmHZPY = class(TForm)
    Label4: TLabel;
    Label5: TLabel;
    Memo1: TMemo;
    Memo2: TMemo;
    MainMenu1: TMainMenu;
    mnuFile: TMenuItem;
    mnuFileOpen: TMenuItem;
    mnuPY: TMenuItem;
    mnuPYHZ: TMenuItem;
    mnuPYHead: TMenuItem;
    OpenDialog1: TOpenDialog;
    procedure mnuFileOpenClick(Sender: TObject);
    procedure mnuPYHZClick(Sender: TObject);
    procedure mnuPYHeadClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FSBMMO1, FSBMMO2: TFMScrollBar;
  public
    { Public declarations }
  end;

procedure db_ShowDllForm_Plugins(var frm: TFormClass; var strParentModuleName, strSubModuleName: PAnsiChar); stdcall;

implementation

{$R *.dfm}

uses untHzPy;

procedure db_ShowDllForm_Plugins(var frm: TFormClass; var strParentModuleName, strSubModuleName: PAnsiChar); stdcall;
begin
  frm                     := TfrmHZPY;
  strParentModuleName     := '文本编辑';
  strSubModuleName        := '汉字标注拼音';
  Application.Handle      := GetMainFormApplication.Handle;
  Application.Icon.Handle := GetDllModuleIconHandle(String(strParentModuleName), string(strSubModuleName));
end;

procedure TfrmHZPY.FormActivate(Sender: TObject);
begin
  FSBMMO1 := TFMScrollBar.Create(nil);
  FSBMMO1.InitScrollbar(Memo1);
  FSBMMO2 := TFMScrollBar.Create(nil);
  FSBMMO2.InitScrollbar(Memo2);
end;

procedure TfrmHZPY.FormDestroy(Sender: TObject);
begin
  FSBMMO1.Free;
  FSBMMO2.Free;
end;

procedure TfrmHZPY.mnuFileOpenClick(Sender: TObject);
begin
  OpenDialog1.Filter := '文本文件(*.txt)|*.txt';
  if not OpenDialog1.Execute then
    Exit;

  Memo1.Lines.LoadFromFile(OpenDialog1.FileName, TEncoding.UTF8);
end;

procedure TfrmHZPY.mnuPYHeadClick(Sender: TObject);
begin
  Memo2.Text := GetHzPyHead(Memo1.Text);
end;

procedure TfrmHZPY.mnuPYHZClick(Sender: TObject);
begin
  Memo2.Text := GetHzPy(Memo1.Text);
end;

end.
