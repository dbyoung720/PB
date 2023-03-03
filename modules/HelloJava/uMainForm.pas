unit uMainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.StrUtils, System.Variants, System.Classes, System.Win.Registry, System.IniFiles, System.Types, System.IOUtils, System.Diagnostics,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.FileCtrl, Vcl.Clipbrd, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Mask, Vcl.Buttons, Winapi.CommCtrl, JNI, JNIUtils, uCommon;

type
  TfrmDelphiCallJava = class(TForm)
    lblJava: TLabel;
    procedure FormCreate(Sender: TObject);
  private
    { Public declarations }
  public
    { Public declarations }
  end;

procedure db_ShowDllForm_Plugins(var frm: TFormClass; var strParentModuleName, strSubModuleName: PAnsiChar); stdcall;

implementation

{$R *.dfm}

procedure db_ShowDllForm_Plugins(var frm: TFormClass; var strParentModuleName, strSubModuleName: PAnsiChar); stdcall;
begin
  frm                     := TfrmDelphiCallJava;
  strParentModuleName     := '程序员工具';
  strSubModuleName        := 'Delphi Call Java';
  Application.Handle      := GetMainFormApplication.Handle;
  Application.Icon.Handle := GetDllModuleIconHandle(String(strParentModuleName), string(strSubModuleName));
end;

function GetJavaVM: TJavaVM; stdcall; external 'PBox.exe';

procedure TfrmDelphiCallJava.FormCreate(Sender: TObject);
var
  jVM              : TJavaVM;
  jEnv             : TJNIEnv;
  strClass         : UTF8String;
  cls              : JClass;
  strMetod         : UTF8String;
  strSign          : UTF8String;
  strArg, strResult: string;
begin
  jVM := GetJavaVM;
  if jVM = nil then
  begin
    ShowMessage('创建 Java 虚拟机失败');
    Exit;
  end;

  { 创建 Java 虚拟机运行环境 }
  jEnv := TJNIEnv.Create(jVM.Env);
  try
    if jEnv = nil then
    begin
      ShowMessage('创建 Java 虚拟机运行环境失败');
      Exit;
    end;

    { 获取 Java 类 }
    strClass := 'Test';
    cls      := jEnv.FindClass(strClass);
    if cls = nil then
    begin
      ShowMessage('没有找到类名');
      Exit;
    end;

    { Java 函数名称、参数类型、参数 }
    strMetod := 'Hello';            // 函数名称
    strSign  := 'String (String)';  // 参数类型，返回值类型
    strArg   := 'from Delphi 11.3'; // 输入参数

    strResult := CallMethod(jEnv, cls, strMetod, strSign, [strArg], True);
    if strResult <> '' then
    begin
      lblJava.Caption := strResult;
    end;

  finally
    jEnv.Free;
  end;
end;

end.
