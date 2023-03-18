library pm;
{$IF CompilerVersion >= 21.0}
{$WEAKLINKRTTI ON}
{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$IFEND}

uses
  System.SysUtils,
  System.Classes,
  uProcessManager in 'uProcessManager.pas' {frmProcessManager};

{$R *.res}

exports
  db_ShowDllForm_Plugins;

begin

end.
