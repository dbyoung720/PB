unit frmCaptureScreen;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.StrUtils, System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.WinXCtrls,
  DosCommand, uCommon;

type
  TfrmCS = class(TForm)
    lbl1: TLabel;
    edtLeft: TEdit;
    lbl2: TLabel;
    edtTop: TEdit;
    lbl3: TLabel;
    edtWidth: TEdit;
    lbl4: TLabel;
    edtHeight: TEdit;
    btnReSelect: TButton;
    btnStartCapture: TButton;
    btnStopCapture: TButton;
    lbl5: TLabel;
    cbbVideoType: TComboBox;
    lbl6: TLabel;
    srchbx1: TSearchBox;
    procedure btnReSelectClick(Sender: TObject);
    procedure btnStartCaptureClick(Sender: TObject);
    procedure btnStopCaptureClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
    FOnReSelect    : TNotifyEvent;
    FhMainForm     : THandle;
    FDOSCommand    : TDosCommand;
    FstrMP4FileName: String;
  end;

procedure ShowCaptureScreenSettingForm(const hMainForm: THandle; const x1, y1, x2, y2: Integer; OnReSelect: TNotifyEvent);

implementation

uses uMain;

{$R *.dfm}

var
  frmCS: TfrmCS;

procedure ShowCaptureScreenSettingForm(const hMainForm: THandle; const x1, y1, x2, y2: Integer; OnReSelect: TNotifyEvent);
begin
  frmCS                := TfrmCS.Create(nil);
  frmCS.left           := Screen.Width - frmCS.Width - 5;
  frmCS.Top            := 5;
  frmCS.edtLeft.Text   := IntToStr(x1);
  frmCS.edtTop.Text    := IntToStr(y1);
  frmCS.edtWidth.Text  := IntToStr(x2 - x1);
  frmCS.edtHeight.Text := IntToStr(y2 - y1);
  frmCS.FhMainForm     := hMainForm;
  frmCS.FOnReSelect    := OnReSelect;
  frmCS.Show;
end;

procedure TfrmCS.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  frmCS.free;
end;

procedure TfrmCS.FormCreate(Sender: TObject);
begin
  FDOSCommand := TDosCommand.Create(Self);
end;

procedure TfrmCS.btnStopCaptureClick(Sender: TObject);
const
  c_strMP4ToGIF = '"%s\ffmpeg.exe" -ss 0 -i "%s" -f gif "%s"';
var
  hFFMPEG: THandle;
begin
  btnStopCapture.Enabled := False;

  { 结束 MP4 录制 }
  hFFMPEG := FindWindow('ConsoleWindowClass', '..\..\bin\Win32\PBox.exe');
  if hFFMPEG = 0 then
    hFFMPEG := FindWindow('ConsoleWindowClass', PChar(ParamStr(0)));
  SendMessage(hFFMPEG, WM_SYSCOMMAND, SC_CLOSE, 0);
  FDOSCommand.Stop;
  FDOSCommand.free;

  { MP4 转换为 GIF }
  if cbbVideoType.ItemIndex = 1 then
    WinExec(PAnsiChar(AnsiString(Format(c_strMP4ToGIF, [GetDllFilePath + 'ffmpeg\bin', FstrMP4FileName, ChangeFileExt(FstrMP4FileName, '.GIF')]))), SW_HIDE);

  { 结束 }
  Close;
  TfrmSnapScreen(GetInstanceFromhWnd(FhMainForm)).ShowMainForm(True);
end;

procedure TfrmCS.btnReSelectClick(Sender: TObject);
begin
  Close;
  FOnReSelect(nil);
end;

procedure TfrmCS.btnStartCaptureClick(Sender: TObject);
const
  c_strCaptonScreen = '"%s\ffmpeg.exe" -f gdigrab -framerate 60 -offset_x %s -offset_y %s -video_size %sx%s -i desktop -f mp4 "%s"';
begin
  btnReSelect.Enabled     := False;
  btnStartCapture.Enabled := False;
  btnStopCapture.Enabled  := True;

  edtLeft.Enabled      := False;
  edtTop.Enabled       := False;
  edtWidth.Enabled     := False;
  edtHeight.Enabled    := False;
  cbbVideoType.Enabled := False;
  srchbx1.Enabled      := False;

  FstrMP4FileName         := Format('%s%sCapture%s.mp4', [srchbx1.Text, IfThen(RightStr(srchbx1.Text, 1) = '\', '', '\'), FormatDateTime('yyyyMMddhhssmm', Now)]);
  FDOSCommand.CommandLine := Format(c_strCaptonScreen, [GetDllFilePath + 'ffmpeg\bin', edtLeft.Text, edtTop.Text, edtWidth.Text, edtHeight.Text, FstrMP4FileName]);
  FDOSCommand.Execute;
end;

end.
