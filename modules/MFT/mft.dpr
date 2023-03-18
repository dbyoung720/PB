library mft;
{$IF CompilerVersion >= 21.0}
{$WEAKLINKRTTI ON}
{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$IFEND}

uses
  System.SysUtils,
  System.Classes,
  Unit1 in 'Unit1.pas' {frmMFT},
  Unit2 in 'Unit2.pas',
  Unit3 in 'Unit3.pas';

{$R *.res}

exports
  db_ShowDllForm_Plugins;

begin
end.
