program PBox;
{$IF CompilerVersion >= 21.0}
{$WEAKLINKRTTI ON}
{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$IFEND}




uses
  Vcl.Forms,
  frmMain in 'frmMain.pas' {frmPBox},
  uBaseForm in 'uBaseForm.pas',
  uUICreate in 'uUICreate.pas',
  uInitJava in 'uInitJava.pas';

{$R *.res}

begin
  OnlyRunOneInstance;
  FstrUserLoginName           := ShowLoginForm(MyOnCheckPassword);
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmPBox, frmPBox);
  Application.Run;

end.
