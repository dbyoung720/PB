library snap;
{$IF CompilerVersion >= 21.0}
{$WEAKLINKRTTI ON}
{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$IFEND}

uses
  System.SysUtils,
  System.Classes,
  uMain in 'uMain.pas' {frmSnapScreen},
  uFullScreen in 'uFullScreen.pas' {frmFullScreen},
  frmCaptureScreen in 'frmCaptureScreen.pas' {frmCS},
  uCommon in '..\uCommon.pas';

{$R *.res}

exports
  db_ShowDllForm_Plugins;

begin

end.
