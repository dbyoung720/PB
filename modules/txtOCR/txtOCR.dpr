library txtOCR;
{$IF CompilerVersion >= 21.0}
{$WEAKLINKRTTI ON}
{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$IFEND}

uses
  System.SysUtils,
  System.Classes,
  uMainForm in 'uMainForm.pas' {frmtxtOCR},
  uCommon in '..\uCommon.pas';

{$R *.res}

exports
  db_ShowDllForm_Plugins;

begin

end.
