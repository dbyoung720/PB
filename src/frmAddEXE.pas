unit frmAddEXE;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.WinXCtrls;

type
  TfrmAddEXE = class(TForm)
    lbl1: TLabel;
    lbl2: TLabel;
    lbl3: TLabel;
    lbl4: TLabel;
    btnSave: TButton;
    btnCancel: TButton;
    edtPModuleName: TEdit;
    edtSModuleName: TEdit;
    edtFormClassName: TEdit;
    edtFormTitleName: TEdit;
    lbl5: TLabel;
    srchbxSelectEXEFile: TSearchBox;
    dlgOpenSelectEXEFile: TOpenDialog;
    procedure btnSaveClick(Sender: TObject);
    procedure srchbxSelectEXEFileInvokeSearch(Sender: TObject);
  private
    { Private declarations }
    FbResult                            : Boolean;
    FstrPModuleName, FstrSModuleName    : String;
    FstrFormClassName, FstrFormTitleName: String;
    FstrEXEFileName                     : String;
  public
    { Public declarations }
  end;

function ShowAddEXEForm(var strPModuleName, strSModuleName, strFormClassName, strFormTitleName, strEXEFileName: String): Boolean;

implementation

{$R *.dfm}

function ShowAddEXEForm(var strPModuleName, strSModuleName, strFormClassName, strFormTitleName, strEXEFileName: String): Boolean;
begin
  with TfrmAddEXE.Create(nil) do
  begin
    FbResult            := False;
    Position            := poScreenCenter;
    edtPModuleName.Text := strPModuleName;
    ShowModal;
    Result := FbResult;
    if Result then
    begin
      strPModuleName   := FstrPModuleName;
      strSModuleName   := FstrSModuleName;
      strFormClassName := FstrFormClassName;
      strFormTitleName := FstrFormTitleName;
      strEXEFileName   := FstrEXEFileName;
    end;
    Free;
  end;
end;

procedure TfrmAddEXE.btnSaveClick(Sender: TObject);
begin
  FstrPModuleName   := edtPModuleName.Text;
  FstrSModuleName   := edtSModuleName.Text;
  FstrFormClassName := edtFormClassName.Text;
  FstrFormTitleName := edtFormTitleName.Text;
  FstrEXEFileName   := srchbxSelectEXEFile.Text;
  if (FstrEXEFileName <> '') and (FstrPModuleName <> '') and (FstrSModuleName <> '') and (FstrFormClassName <> '') and (FstrFormTitleName <> '') then
  begin
    FbResult := True;
    Close;
  end
  else
  begin
    MessageBox(Handle, 'EXE 信息不能为空', '系统提示：', MB_OK or MB_ICONERROR);
    Exit;
  end;
end;

procedure TfrmAddEXE.srchbxSelectEXEFileInvokeSearch(Sender: TObject);
begin
  if not dlgOpenSelectEXEFile.Execute(Handle) then
    Exit;

  srchbxSelectEXEFile.Text := dlgOpenSelectEXEFile.FileName;
  edtSModuleName.Text      := ChangeFileExt(ExtractFileName(dlgOpenSelectEXEFile.FileName), '') + '(EXE)';
end;

end.
