program PBox;
{$IF CompilerVersion >= 21.0}
{$WEAKLINKRTTI ON}
{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$IFEND}

{$R *.dres}

uses
  Vcl.Forms,
  frmMain in 'frmMain.pas' {frmPBox},
  uBaseForm in 'uBaseForm.pas',
  uUICreate in 'uUICreate.pas';

{$R *.res}

begin
  OnlyRunOneInstance;
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmPBox, frmPBox);
  Application.Run;

end.
