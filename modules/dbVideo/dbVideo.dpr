library dbVideo;
{$IF CompilerVersion >= 21.0}
{$WEAKLINKRTTI ON}
{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$IFEND}

uses
  System.SysUtils,
  System.Classes,
  uCommon in '..\uCommon.pas',
  db.VideoSDK in 'db.VideoSDK.pas',
  Unit1 in 'Unit1.pas' {frmVideo};

{$R *.res}

exports
  db_ShowDllForm_Plugins;

begin
end.
