unit uMainForm;
{$WARN UNIT_PLATFORM OFF}

interface

uses Winapi.Windows, System.SysUtils, System.Variants, System.Classes, System.Types, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, System.Diagnostics, JNI, JNIUtils, uCommon;

type
  TfrmOpenCV = class(TForm)
    img1: TImage;
    mmoLOG: TMemo;
    spl1: TSplitter;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FjEnv: TJNIEnv;
    { 获取 OpenCV 编译信息 }
    procedure OpenCV_getBuildInformation;
    { 读取图片 }
    function OpenCV_imread(): Pointer;
    { Mat 转 Bitmap }
    procedure MatToBitmap(pMat: JObject);
  public
    { 显示图片 }
    procedure OpenCV_imshow(const strTitle: String; pMat: JObject);
  end;

procedure db_ShowDllForm_Plugins(var frm: TFormClass; var strParentModuleName, strSubModuleName: PAnsiChar); stdcall;

implementation

{$R *.dfm}

procedure db_ShowDllForm_Plugins(var frm: TFormClass; var strParentModuleName, strSubModuleName: PAnsiChar); stdcall;
begin
  frm                     := TfrmOpenCV;
  strParentModuleName     := '程序员工具';
  strSubModuleName        := 'JavaCV';
  Application.Handle      := GetMainFormApplication.Handle;
  Application.Icon.Handle := GetDllModuleIconHandle(String(strParentModuleName), string(strSubModuleName));
end;

{ Java 虚拟机是全局的，所以放在主程序中创建 }
function GetJavaVM: TJavaVM; stdcall; external 'PBox.exe';

procedure TfrmOpenCV.FormDestroy(Sender: TObject);
begin
  if FjEnv <> nil then
    FjEnv.Free;
end;

procedure TfrmOpenCV.FormCreate(Sender: TObject);
var
  jVM : TJavaVM;
  pMat: JObject;
begin
  jVM   := GetJavaVM;
  FjEnv := TJNIEnv.Create(jVM.Env);

  { 获取 OpenCV 编译信息 }
  OpenCV_getBuildInformation;

  with TStopwatch.StartNew do
  begin
    { 加载图片 }
    pMat := OpenCV_imread();

    { Mat 转 Bitmap }
    MatToBitmap(pMat);

    mmoLOG.Lines.Add(Format('合计用时：%d 毫秒', [ElapsedMilliseconds]));
  end;
end;

{ 获取 OpenCV 编译信息 }
procedure TfrmOpenCV.OpenCV_getBuildInformation;
var
  strClass: UTF8String;
  cls     : JClass;
  strMetod: UTF8String;
  strSign : UTF8String;
  strBuild: String;
begin
  strClass := 'org/opencv/core/Core';
  cls      := FjEnv.FindClass(strClass);
  strMetod := 'getBuildInformation';
  strSign  := 'String ()';
  strBuild := CallMethod(FjEnv, cls, strMetod, strSign, [], True);
  strBuild := strBuild.Replace(#$A, #$D#$A, [rfReplaceAll]);
  mmoLOG.Lines.Add(strBuild);
end;

{ 读取图片 }
function TfrmOpenCV.OpenCV_imread(): Pointer;
var
  strClass   : UTF8String;
  cls        : JClass;
  mid        : JMethodID;
  strFileName: String;
begin
  strFileName := GetDllFilePath + 'java\test.jpg';
  strClass    := 'org/opencv/imgcodecs/Imgcodecs';
  cls         := FjEnv.FindClass(strClass);
  mid         := FjEnv.GetStaticMethodID(cls, 'imread', '(Ljava/lang/String;I)Lorg/opencv/core/Mat;');
  Result      := FjEnv.CallStaticObjectMethod(cls, mid, [strFileName, 1]); // 0: 灰度图  1: RGB
end;

{ 显示图片 }
procedure TfrmOpenCV.OpenCV_imshow(const strTitle: String; pMat: JObject);
var
  strClass: UTF8String;
  cls     : JClass;
  mid     : JMethodID;
begin
  strClass := 'org/opencv/highgui/HighGui';
  cls      := FjEnv.FindClass(strClass);
  mid      := FjEnv.GetStaticMethodID(cls, 'imshow', '(Ljava/lang/String;Lorg/opencv/core/Mat;)V');
  FjEnv.CallStaticVoidMethod(cls, mid, [strTitle, pMat]);

  { 此句必不可少,否则窗体一闪而逝 }
  mid := FjEnv.GetStaticMethodID(cls, 'waitKey', '()V');
  FjEnv.CallStaticVoidMethod(cls, mid, []);
end;

{ Mat 转 Bitmap }
procedure TfrmOpenCV.MatToBitmap(pMat: JObject);
var
  strClass           : UTF8String;
  cls                : JClass;
  intWidth, intHeight: Integer;
  nChannels          : Integer;
  intRGBASize        : Integer;
  intReadSize        : Integer;
  JarrRGB            : JByteArray;
  pRGB               : PJByte;
  bmp                : TBitmap;
  bCopy              : Boolean;
begin
  strClass  := 'org/opencv/core/Mat';
  cls       := FjEnv.FindClass(strClass);
  intWidth  := FjEnv.CallIntMethod(pMat, FjEnv.GetMethodID(cls, 'width', '()I'), []);
  intHeight := FjEnv.CallIntMethod(pMat, FjEnv.GetMethodID(cls, 'height', '()I'), []);
  nChannels := FjEnv.CallIntMethod(pMat, FjEnv.GetMethodID(cls, 'channels', '()I'), []);
  mmoLOG.Lines.Add(Format('图像宽度：%d  图像高度：%d  通道数：%d', [intWidth, intHeight, nChannels]));

  { 获取图像像素 Java 数组 }
  intRGBASize := intWidth * intHeight * nChannels;
  JarrRGB     := FjEnv.NewByteArray(intRGBASize);
  intReadSize := FjEnv.CallIntMethod(pMat, FjEnv.GetMethodID(cls, 'get', '(II[B)I'), [0, 0, JarrRGB]);
  if intReadSize <> intRGBASize then
    Exit;

  { 图像像素 Java 数组到 Delphi 像素指针 }
  bCopy := False;
  pRGB  := FjEnv.GetByteArrayElements(JarrRGB, bCopy);
  bmp   := TBitmap.Create;
  try
    bmp.PixelFormat := pf24bit;
    bmp.Width       := intWidth;
    bmp.Height      := intHeight;
    SetBitmapBits(bmp.Handle, intRGBASize, pRGB);
    img1.Picture.Bitmap.Assign(bmp);
  finally
    FjEnv.ReleaseByteArrayElements(JarrRGB, pRGB, 0);
    bmp.Free;
  end;
end;

end.
