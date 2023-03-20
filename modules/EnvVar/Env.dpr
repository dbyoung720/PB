library Env;
{$IF CompilerVersion >= 21.0}
{$WEAKLINKRTTI ON}
{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$IFEND}

uses
  System.SysUtils,
  System.Classes,
  Unit4 in 'Unit4.pas' {frmEnvVar};

{$R *.res}

exports
  db_ShowDllForm_Plugins;

begin
end.
