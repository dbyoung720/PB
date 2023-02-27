library ccpu;
{$IF CompilerVersion >= 21.0}
{$WEAKLINKRTTI ON}
{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$IFEND}

uses
  System.SysUtils,
  System.Classes,
  Unit1 in 'Unit1.pas' {frmCheckCPU},
  uCommon in '..\uCommon.pas';

{$R *.res}

exports
  db_ShowDllForm_Plugins;

begin

end.
