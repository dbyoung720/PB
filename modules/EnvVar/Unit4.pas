unit Unit4;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, System.IOUtils, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, DosCommand, uCommon;

type
  TfrmEnvVar = class(TForm)
    Memo1: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    DosCommand1: TDosCommand;
  end;

procedure db_ShowDllForm_Plugins(var frm: TFormClass; var strParentModuleName, strSubModuleName: PAnsiChar); stdcall;

implementation

{$R *.dfm}

procedure db_ShowDllForm_Plugins(var frm: TFormClass; var strParentModuleName, strSubModuleName: PAnsiChar); stdcall;
begin
  frm                     := TfrmEnvVar;
  strParentModuleName     := '系统管理';
  strSubModuleName        := '系统环境变量';
  Application.Handle      := GetMainFormApplication.Handle;
  Application.Icon.Handle := GetDllModuleIconHandle(String(strParentModuleName), string(strSubModuleName));
end;

procedure TfrmEnvVar.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  DosCommand1.Free;
end;

procedure TfrmEnvVar.FormCreate(Sender: TObject);
begin
  DosCommand1                        := TDosCommand.Create(nil);
  DosCommand1.InputToOutput          := False;
  DosCommand1.MaxTimeAfterBeginning  := 0;
  DosCommand1.MaxTimeAfterLastOutput := 1000;
  DosCommand1.CommandLine            := 'cmd /c "set"';
  DosCommand1.CurrentDir             := 'c:\windows';
  Memo1.Lines.Clear;
  DosCommand1.OutputLines := Memo1.Lines;
  DosCommand1.Execute;
  Memo1.Lines := DosCommand1.Lines;
end;

end.
