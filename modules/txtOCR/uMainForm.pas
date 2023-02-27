unit uMainForm;
{$WARN UNIT_PLATFORM OFF}

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, System.IOUtils, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtDlgs, Vcl.WinXCtrls, Vcl.ExtCtrls, Vcl.Imaging.jpeg,
  uCommon;

type
  TfrmtxtOCR = class(TForm)
    srchbxFile: TSearchBox;
    dlgOpenPic1: TOpenPictureDialog;
    imgShow: TImage;
    grpText: TGroupBox;
    mmoText: TMemo;
    procedure srchbxFileInvokeSearch(Sender: TObject);
  private
    procedure TextRegconize(const strImageFileName: string);
  public
    { Public declarations }
  end;

procedure db_ShowDllForm_Plugins(var frm: TFormClass; var strParentModuleName, strSubModuleName: PAnsiChar); stdcall;

implementation

{$R *.dfm}

procedure db_ShowDllForm_Plugins(var frm: TFormClass; var strParentModuleName, strSubModuleName: PAnsiChar); stdcall;
begin
  frm                     := TfrmtxtOCR;
  strParentModuleName     := '图形图像';
  strSubModuleName        := '文本识别';
  Application.Handle      := GetMainFormApplication.Handle;
  Application.Icon.Handle := GetDllModuleIconHandle(String(strParentModuleName), string(strSubModuleName));
end;

procedure TfrmtxtOCR.srchbxFileInvokeSearch(Sender: TObject);
begin
  if not dlgOpenPic1.Execute() then
    Exit;

  srchbxFile.Text := dlgOpenPic1.FileName;
  imgShow.Picture.LoadFromFile(dlgOpenPic1.FileName);
  TextRegconize(dlgOpenPic1.FileName);
end;

procedure TfrmtxtOCR.TextRegconize(const strImageFileName: string);
var
  strToolsPath     : String;
  strOutputFileName: String;
begin

  grpText.Visible   := True;
  strToolsPath      := ExtractFilePath(ParamStr(0)) + 'plugins\EXE\tesseract';
  strOutputFileName := TPath.GetTempPath + Formatdatetime('yyyyMMddhhmmss', Now);
  WinExec(PAnsiChar(AnsiString(Format('"%s\tesseract.exe" "%s" "%s" -l chi_sim', [strToolsPath, srchbxFile.Text, strOutputFileName]))), SW_HIDE);
  while True do
  begin
    Application.ProcessMessages;
    if FileExists(strOutputFileName + '.txt') then
      Break;
  end;

  while True do
  begin
    try
      DelayTime(100);
      mmoText.Lines.LoadFromFile(strOutputFileName + '.txt', TEncoding.UTF8);
      DeleteFile(strOutputFileName + '.txt');
      Break;
    except
    end;
  end;
end;

end.
