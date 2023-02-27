library sp;
{$IF CompilerVersion >= 21.0}
{$WEAKLINKRTTI ON}
{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$IFEND}

uses
  System.SysUtils,
  System.Classes,
  untSysSearch in 'untSysSearch.pas' {frmSysSearch},
  uCommon in '..\uCommon.pas';

{$R *.res}

exports
  db_ShowDllForm_Plugins;

begin

end.
