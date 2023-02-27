unit uImgListEx;

interface

uses Windows, SysUtils, Classes, Graphics, Controls, Commctrl, ImgList, Consts;

type
  TImageListEx = class(TImageList)
  public
    procedure LoadFromFile(const FileName: string); // 实现API方式保存
    procedure LoadFromStream(Stream: TStream);
    procedure SaveToFile(const FileName: string);
    procedure SaveToStream(Stream: TStream);
    procedure LoadFromFileEx(const FileName: string); // 实现自定义方式保存
    procedure LoadFromStreamEx(Stream: TStream);
    procedure SaveToFileEx(const FileName: string);
    procedure SaveToStreamEx(Stream: TStream);
  end;

implementation

{ TImageListEx }
procedure TImageListEx.LoadFromFile(const FileName: string);
var
  Stream: TStream;
begin
  Stream := TFileStream.Create(FileName, fmOpenRead);
  try
    LoadFromStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure TImageListEx.LoadFromFileEx(const FileName: string);
var
  Stream: TStream;
begin
  Stream := TFileStream.Create(FileName, fmOpenRead);
  try
    LoadFromStreamEx(Stream);
  finally
    Stream.Free;
  end;
end;

procedure TImageListEx.LoadFromStream(Stream: TStream);
var
  SA: TStreamAdapter;
begin
  SA := TStreamAdapter.Create(Stream);
  try
    Handle := ImageList_Read(SA); // 将当前图像列表的句柄指向从二进制流中得到的句柄
    if Handle = 0 then
      raise EReadError.CreateRes(@SImageReadFail);
  finally
    SA.Free;
  end;
end;

procedure TImageListEx.LoadFromStreamEx(Stream: TStream);
var
  Width, Height: Integer;
  Bitmap, Mask : TBitmap;
  BinStream    : TMemoryStream;
  procedure LoadImageFromStream(Image: TBitmap);
  var
    Count: DWORD;
  begin
    Image.Assign(nil);
    Stream.ReadBuffer(Count, SizeOf(Count)); // 首先读出位图的大小
    BinStream.Clear;
    BinStream.CopyFrom(Stream, Count); // 接着读出位图
    BinStream.Position := 0;           // 流指针复位
    Image.LoadFromStream(BinStream);
  end;

begin
  Stream.ReadBuffer(Height, SizeOf(Height));
  Stream.ReadBuffer(Width, SizeOf(Width));
  Self.Height := Height;
  Self.Width  := Width; // 恢复图像列表原来的高度、宽度
  Bitmap      := TBitmap.Create;
  Mask        := TBitmap.Create;
  BinStream   := TMemoryStream.Create;
  try
    while Stream.Position <> Stream.Size do
    begin
      LoadImageFromStream(Bitmap); // 从二进制流中读出位图
      LoadImageFromStream(Mask);   // 从二进制流中读出掩码位图
      Add(Bitmap, Mask);           // 将位图及其掩码位图合并添加到图像列表中
    end;
  finally
    Bitmap.Free;
    Mask.Free;
    BinStream.Free;
  end;
end;

procedure TImageListEx.SaveToFile(const FileName: string);
var
  Stream: TStream;
begin
  Stream := TFileStream.Create(FileName, fmCreate);
  try
    SaveToStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure TImageListEx.SaveToFileEx(const FileName: string);
var
  Stream: TStream;
begin
  Stream := TFileStream.Create(FileName, fmCreate);
  try
    SaveToStreamEx(Stream);
  finally
    Stream.Free;
  end;
end;

procedure TImageListEx.SaveToStream(Stream: TStream);
var
  SA: TStreamAdapter;
begin
  SA := TStreamAdapter.Create(Stream);
  try
    if not ImageList_Write(Handle, SA) then // 将当前图像列表保存到二进制流中
      raise EWriteError.CreateRes(@SImageWriteFail);
  finally
    SA.Free;
  end;
end;

procedure TImageListEx.SaveToStreamEx(Stream: TStream);
var
  I            : Integer;
  Width, Height: Integer;
  Bitmap, Mask : TBitmap;
  BinStream    : TMemoryStream;
  procedure SetImage(Image: TBitmap; IsMask: Boolean);
  begin
    Image.Assign(nil); // 清除上一次保存的图像，避免出现图像重叠
    with Image do
    begin
      if IsMask then
        Monochrome := True; // 掩码位图必须使用单色
      Height       := Self.Height;
      Width        := Self.Width;
    end;
  end;
  procedure SaveImageToStream(Image: TBitmap);
  var
    Count: DWORD;
  begin
    BinStream.Clear;
    Image.SaveToStream(BinStream);
    Count := BinStream.Size;
    Stream.WriteBuffer(Count, SizeOf(Count)); // 首先保存位图的大小
    Stream.CopyFrom(BinStream, 0);            // 接着保存位图
  end;

begin
  Height := Self.Height;
  Width  := Self.Width;
  Stream.WriteBuffer(Height, SizeOf(Height)); // 保存原图像列表的高度
  Stream.WriteBuffer(Width, SizeOf(Width));   // 保存将原图像列表的宽度
  Bitmap    := TBitmap.Create;
  Mask      := TBitmap.Create;
  BinStream := TMemoryStream.Create;
  try
    for I := 0 to Count - 1 do // 遂一保存图像列表中的图像
    begin
      SetImage(Bitmap, False);
      SetImage(Mask, True);
      GetImages(I, Bitmap, Mask); // 取得指定索引号的位图及其掩码位图
      SaveImageToStream(Bitmap);  // 保存位图到二进制流中
      SaveImageToStream(Mask);    // 保存掩码位图到二进制流中
    end;
  finally
    Bitmap.Free;
    Mask.Free;
    BinStream.Free;
  end;
end;

end.
