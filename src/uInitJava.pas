unit uInitJava;
{
  Func : Global init java vm
  Auth : dbyoung@sina.com
  Time : 2023-03-01
}

interface

uses Winapi.Windows, System.SysUtils, JNI, JNIUtils;

implementation

var
  FJavaVM: TJavaVM = nil;

procedure LoadOpenCVDll;
var
  strDllFileName: String;
  strClass      : UTF8String;
  cls           : JClass;
  mid           : JMethodID;
  jEnv          : TJNIEnv;
begin
  strDllFileName := ExtractFilePath(ParamStr(0)) + 'plugins\SDK\OpenCV\4.6.0\bin\opencv_java460.dll';
  if not FileExists(strDllFileName) then
    Exit;

  { 加载 OpenCV Java DLL }
  jEnv := TJNIEnv.Create(FJavaVM.Env);
  try
    SetDllDirectory(PChar(ExtractFilePath(strDllFileName)));
    strClass := 'lcv';
    cls      := jEnv.FindClass(strClass);
    mid      := jEnv.GetStaticMethodID(cls, 'LoadOpenJavaDll', '(Ljava/lang/String;)V');
    jEnv.CallStaticVoidMethod(cls, mid, [strDllFileName]);
  finally
    jEnv.free;
  end;
end;

procedure InitJava;
var
  strJavaFileName: String;
  Options        : array [0 .. 0] of JavaVMOption;
  VM_args        : JavaVMInitArgs;
  ErrCode        : Integer;
begin
  SetDllDirectory(PChar(ExtractFilePath(ParamStr(0)) + 'plugins'));
{$IFDEF CPUX86}
  strJavaFileName := ExtractFilePath(ParamStr(0)) + 'plugins\SDK\JRE\bin\client\jvm.dll';
{$ELSE }
  strJavaFileName := ExtractFilePath(ParamStr(0)) + 'plugins\SDK\JRE\bin\server\jvm.dll';
{$ENDIF }
  if not FileExists(strJavaFileName) then
    Exit;

  { 创建 Java 虚拟机 }
  FJavaVM                    := TJavaVM.Create(JNI_VERSION_1_8, strJavaFileName);
  Options[0].optionString    := PAnsiChar(AnsiString('-Djava.class.path=' + ExtractFilePath(ParamStr(0)) + 'plugins\Java'));
  VM_args.version            := JNI_VERSION_1_2;
  VM_args.Options            := @Options;
  VM_args.nOptions           := 1;
  VM_args.ignoreUnrecognized := True;
  ErrCode                    := FJavaVM.LoadVM(VM_args);
  if ErrCode < 0 then
  begin
    FJavaVM := nil;
    Exit;
  end;

  { 加载 OpenCV DLL }
  LoadOpenCVDll;
end;

procedure FreeJava;
begin
  if FJavaVM = nil then
    Exit;

  FJavaVM.DestroyJavaVM;
  FJavaVM.free;
end;

function GetJavaVM: TJavaVM; stdcall;
begin
  Result := FJavaVM;
end;

exports GetJavaVM;

initialization
  InitJava;

finalization
  FreeJava;

end.
