unit uScrollBar;
{
  Func : Owner Draw Scrollbar UI
  Auth : dbyoung@sina.com
  Time : 2010-03-20
}

interface

uses Windows, Classes, Graphics, Controls, Messages, ExtCtrls, PngImage, Forms;

type
  TScrollBarPos = record
    Btn: Integer;
    ScrollArea: Integer;
    Thumb: Integer;
    ThumbPos: Integer;
    MsgID: Integer;
  end;

  TScrollBarState = (ssNormal, ssHover, ssClick);

type
  TDBScrollBar = class(TCustomPanel)
  private
    procedure WMLButtonDown(var aMsg: TMessage);    message WM_LButtonDown;
    procedure WMMouseMove(var aMsg: TMessage);      message WM_MouseMove;
    procedure WMMouseLeave(var aMsg: TMessage);     message WM_MouseLeave;
    procedure WMLButtonDBClick(var aMsg: TMessage); message WM_LBUTTONDBLCLK;
    procedure WMLButtonUp(var aMsg: TMessage);      message WM_LButtonUp;
    procedure WMERASEBKGND(var Msg: TMessage);      message WM_ERASEBKGND;
  protected
    FLen                    : Integer;
    FthumbTop, Fthumbbottom : Integer;
    FOffsetSC, Ftrackp      : tpoint;
    Ftrackthumb             : Integer;
    FLButtonDown            : Boolean;
    FsbDir                  : Integer;
    FScrollPos              : Integer;
    procedure Paint; override;
    procedure GetThumb(rc: TRect);
    function GetScrollPos(p: tpoint): Integer;
  public
    FCW       : Integer;
    FhWnd     : THandle;
    FControl  : TWincontrol;
    FsbType   : byte;
    FsbRect   : TRect;
    FsbVisible: Boolean;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Attach(aControl: TWincontrol; aType: byte);
    procedure AttachhWnd(ahWnd: THandle; aType: byte);
    procedure SetPosition(ahWnd: THandle);
    procedure ButtonUp;
    procedure HideScrollbar;
  end;

  TFMControl = class(TComponent)
  protected
    procedure Default(var Msg: TMessage);
    procedure Invalidate;
  public
    FhWnd       : hWnd;
    FOldWndProc : TWndMethod;
    FControl    : TWincontrol;
    procedure FillBG( dc:HDC; rc:TRect);
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure NewWndProc(var Message: TMessage);
    procedure AfterProc(var Message: TMessage); virtual;
    procedure PaintControl(aDC: HDC = 0); virtual;
    procedure DrawControl(aDC: HDC; rc: TRect); virtual;
  end;

  TFMScrollBar = class(TFMControl)
  protected
    procedure SetScrollbarPos(Message: TMessage);
  public
    Fhb, Fvb: TDBScrollBar;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure InitScrollbar(aControl: TWincontrol);
    procedure DrawControl(dc: HDC; rc: TRect); override;
    procedure AfterProc(var Message: TMessage); override;
  end;

{$R *.res}

implementation

const
  iResHeight    = 16;

var
  PngSB: TPngImage;

function Point(AX, AY: Integer): tpoint;
begin
  Result.X := AX;
  Result.Y := AY;
end;

function MakeRect(Left, Top, Width, Height: Integer): TRect;
begin
  Result.Left   := Left;
  Result.Top    := Top;
  Result.Right  := Left + Width;
  Result.Bottom := Top + Height;
end;

procedure DrawRect(DestDC: HDC; DestRect: TRect; SrcDC: HDC; SrcX: Integer; SrcY: Integer);
begin
  BitBlt(DestDC, DestRect.Left, DestRect.Top, DestRect.Right - DestRect.Left, DestRect.Bottom - DestRect.Top, SrcDC, SrcX, SrcY, SRCCOPY);
end;

procedure StretchRect(DestDC: HDC; DestRect: TRect; SrcDC: HDC; SrcRect: TRect);
begin
  StretchBlt(DestDC, DestRect.Left, DestRect.Top, DestRect.Right - DestRect.Left, DestRect.Bottom - DestRect.Top, SrcDC, SrcRect.Left, SrcRect.Top, SrcRect.Right - SrcRect.Left, SrcRect.Bottom - SrcRect.Top, SRCCOPY);
end;

const
  intOffsetX = 2;

{ 上箭头 }
procedure DrawArrowUp(Canvas: TCanvas; sRect: TRect; sbState: TScrollBarState);
begin
  case sbState of
    ssNormal:
      Canvas.CopyRect(Rect(intOffsetX, 0, iResHeight + intOffsetX, iResHeight), PngSB.Canvas, Rect(0, 0, iResHeight, iResHeight));
    ssHover:
      Canvas.CopyRect(Rect(intOffsetX, 0, iResHeight + intOffsetX, iResHeight), PngSB.Canvas, Rect(iResHeight * 4, 0, iResHeight + iResHeight * 4, iResHeight));
    ssClick:
      Canvas.CopyRect(Rect(intOffsetX, 0, iResHeight + intOffsetX, iResHeight), PngSB.Canvas, Rect(iResHeight * 8, 0, iResHeight + iResHeight * 8, iResHeight));
  end;
end;

{ 下箭头 }
procedure DrawArrowDown(Canvas: TCanvas; sRect: TRect; sbState: TScrollBarState);
begin
  case sbState of
    ssNormal:
      Canvas.CopyRect(Rect(intOffsetX, sRect.Bottom - iResHeight, iResHeight + intOffsetX, sRect.Bottom), PngSB.Canvas, Rect(16, 0, iResHeight + 16, iResHeight));
    ssHover:
      Canvas.CopyRect(Rect(intOffsetX, sRect.Bottom - iResHeight, iResHeight + intOffsetX, sRect.Bottom), PngSB.Canvas, Rect(iResHeight * 5, 0, iResHeight + iResHeight * 5, iResHeight));
    ssClick:
      Canvas.CopyRect(Rect(intOffsetX, sRect.Bottom - iResHeight, iResHeight + intOffsetX, sRect.Bottom), PngSB.Canvas, Rect(iResHeight * 9, 0, iResHeight + iResHeight * 9, iResHeight));
  end;
end;

{ 左箭头 }
procedure DrawArrowLeft(Canvas : TCanvas; sRect : TRect; sbState : TScrollBarState);
begin
  case sbState of
    ssNormal:
      Canvas.CopyRect(Rect(intOffsetX + 2, intOffsetX, intOffsetX + 2 + iResHeight, intOffsetX + iResHeight), PngSB.Canvas, Rect(iResHeight * 13, 0, iResHeight + iResHeight * 13, iResHeight));
    ssHover:
      Canvas.CopyRect(Rect(intOffsetX + 2, intOffsetX, intOffsetX + 2 + iResHeight, intOffsetX + iResHeight), PngSB.Canvas, Rect(iResHeight * 15, 0, iResHeight + iResHeight * 15, iResHeight));
    ssClick:
      Canvas.CopyRect(Rect(intOffsetX + 2, intOffsetX, intOffsetX + 2 + iResHeight, intOffsetX + iResHeight), PngSB.Canvas, Rect(iResHeight * 17, 0, iResHeight + iResHeight * 17, iResHeight));
  end;
end;

{ 右箭头 }
procedure DrawArrowRight(Canvas : TCanvas; sRect : TRect; sbState : TScrollBarState);
begin
  case sbState of
    ssNormal:
      Canvas.CopyRect(Rect(sRect.Right - iResHeight, intOffsetX, sRect.Right, intOffsetX + iResHeight), PngSB.Canvas, Rect(iResHeight * 12, 0, iResHeight + iResHeight * 12, iResHeight));
    ssHover:
      Canvas.CopyRect(Rect(sRect.Right - iResHeight, intOffsetX, sRect.Right, intOffsetX + iResHeight), PngSB.Canvas, Rect(iResHeight * 14, 0, iResHeight + iResHeight * 14, iResHeight));
    ssClick:
      Canvas.CopyRect(Rect(sRect.Right - iResHeight, intOffsetX, sRect.Right, intOffsetX + iResHeight), PngSB.Canvas, Rect(iResHeight * 16, 0, iResHeight + iResHeight * 16, iResHeight));
  end;
end;

{ 垂直滚动条 }
procedure DrawThumbVB(Canvas: TCanvas; sRect: TRect; sbState: TScrollBarState);
begin
  case sbState of
    ssNormal:
      begin
        Canvas.Pen.Color   := RGB(169, 169, 169);
        Canvas.Brush.Color := RGB(169, 169, 169);
        Canvas.Brush.Style := bsSolid;
        Canvas.RoundRect(sRect.Left + 6, sRect.Top, sRect.Right - 4, sRect.Bottom, 4, 4);
      end;
    ssHover:
      begin
        Canvas.Pen.Color   := RGB(139, 139, 139);
        Canvas.Brush.Color := RGB(139, 139, 139);
        Canvas.Brush.Style := bsSolid;
        Canvas.RoundRect(sRect.Left + 6, sRect.Top, sRect.Right - 4, sRect.Bottom, 4, 4);
      end;
    ssClick:
      begin
        Canvas.Pen.Color   := RGB(107, 109, 108);
        Canvas.Brush.Color := RGB(107, 109, 108);
        Canvas.Brush.Style := bsSolid;
        Canvas.RoundRect(sRect.Left + 6, sRect.Top, sRect.Right - 4, sRect.Bottom, 4, 4);
      end;
  end;
end;

{ 水平滚动条 }
procedure DrawThumbHB(Canvas: TCanvas; sRect: TRect; sbState: TScrollBarState);
begin
  case sbState of
    ssNormal:
      begin
        Canvas.Pen.Color   := RGB(169, 169, 169);
        Canvas.Brush.Color := RGB(169, 169, 169);
        Canvas.Brush.Style := bsSolid;
        Canvas.RoundRect(sRect.Left + 4, sRect.Top + 6, sRect.Right - 4, sRect.Bottom - 4, 4, 4);
      end;
    ssHover:
      begin
        Canvas.Pen.Color   := RGB(139, 139, 139);
        Canvas.Brush.Color := RGB(139, 139, 139);
        Canvas.Brush.Style := bsSolid;
        Canvas.RoundRect(sRect.Left + 4, sRect.Top + 6, sRect.Right - 4, sRect.Bottom - 4, 4, 4);
      end;
    ssClick:
      begin
        Canvas.Pen.Color   := RGB(107, 109, 108);
        Canvas.Brush.Color := RGB(107, 109, 108);
        Canvas.Brush.Style := bsSolid;
        Canvas.RoundRect(sRect.Left + 4, sRect.Top + 6, sRect.Right - 4, sRect.Bottom - 4, 4, 4);
      end;
  end;
end;

{ 滚动条垂直背景 }
procedure DrawTrackVB(Canvas: TCanvas; sRect: TRect);
begin
  Canvas.Pen.Color   := RGB(216, 215, 213);
  Canvas.Brush.Color := RGB(216, 215, 213);
  Canvas.Brush.Style := bsSolid;
  Canvas.RoundRect(6, iResHeight, 6 + 7, sRect.Bottom, 4, 4);
end;

{ 滚动条水平背景 }
procedure DrawTrackHB(Canvas: TCanvas; sRect: TRect);
begin
  Canvas.Pen.Color   := RGB(216, 215, 213);
  Canvas.Brush.Color := RGB(216, 215, 213);
  Canvas.Brush.Style := bsSolid;
  Canvas.RoundRect(sRect.Left + 6, sRect.Top + 6, sRect.Right - 4, sRect.Bottom - 4, 4, 4);
end;

{ TFMControl }

procedure TFMControl.AfterProc(var Message: TMessage);
begin
  case message.Msg of
    WM_Paint:                       PaintControl(message.WParam);
    WM_KILLFOCUS, WM_SETFOCUS:      Invalidate;
    WM_SETTEXT:                     Invalidate;
    WM_ENABLE, CM_ENABLEDCHANGED:   Invalidate;
  end;
end;

constructor TFMControl.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FhWnd := 0;
  FControl := nil;
end;

procedure TFMControl.Default(var Msg: TMessage);
begin
  if Assigned(FOldWndProc) then
    FOldWndProc(Msg);
end;

destructor TFMControl.Destroy;
begin
  if Assigned(FOldWndProc) then
  begin
    if FControl <> nil then
      FControl.WindowProc := FOldWndProc;

    FOldWndProc := nil;
  end;

  inherited Destroy;
end;

procedure TFMControl.DrawControl(aDC: HDC; rc: TRect);
begin

end;

procedure TFMControl.FillBG(dc: HDC; rc: TRect);
var
  Brush: HBrush;
begin
  Brush := CreateSolidBrush(RGB(236,233,216));
  try
    fillrect(dc,rc,brush);
  finally
    DeleteObject(Brush);
  end;
end;

procedure TFMControl.Invalidate;
begin
  if (FhWnd > 0) then
  begin
    InvalidateRect(FhWnd, nil, True);
    UpdateWindow(FhWnd);
  end;
end;

procedure TFMControl.NewWndProc(var Message: TMessage);
begin
  Default(Message);
  AfterProc(message);
end;

procedure TFMControl.PaintControl(aDC: HDC = 0);
var
  dc: HDC;
  Rect: TRect;
begin
  if GetWindowRect(FhWnd, Rect) then
  begin
    try
      OffsetRect(Rect, -Rect.Left, -Rect.Top);
      if (aDC = 0) then
      begin
        dc := GetWindowDC(FhWnd);
        try
          DrawControl(dc, Rect);
        finally
          ReleaseDC(FhWnd, dc);
        end;
      end
      else
        DrawControl(aDC, Rect);
    except
    end;
  end;
end;

{ TDBScrollBar }

procedure TDBScrollBar.Attach(aControl: TWincontrol; aType: byte);
begin
  FhWnd         := aControl.Handle;
  FControl      := aControl;
  FsbType       := aType;
  FsbDir        := FsbType;
  ParentWindow  := GetParent(FhWnd);
  SetPosition(FhWnd);
end;

procedure TDBScrollBar.AttachhWnd(ahWnd: THandle; aType: byte);
begin
  FhWnd     := ahWnd;
  FControl  := nil;
  FsbType   := aType;
  FsbDir    := FsbType;

  ParentWindow := GetParent(FhWnd);
  SetPosition(FhWnd);
end;

procedure TDBScrollBar.ButtonUp;
begin
  FLButtonDown := False;
  ReleaseCapture;
  if FsbType = SB_CTL then
    Invalidate;
end;

constructor TDBScrollBar.Create(AOwner: TComponent);
begin
  FControl := nil;
  FCW      := GetSystemMetrics(SM_CXHSCROLL);
  FhWnd    := 0;
  inherited Create(AOwner);
  FScrollPos := -1;
end;

destructor TDBScrollBar.Destroy;
begin
  inherited Destroy;
end;

{ 获取滚动条状态 }
function TDBScrollBar.GetScrollPos(p: tpoint): Integer;
var
  X: Integer;
begin
  if FsbDir = SB_Horz then
    X := p.X
  else
    X := p.Y;

  if X < FCW then
    Result := SB_LINEUP
  else if X < FthumbTop then
    Result := SB_PAGEUP
  else if X < Fthumbbottom then
    Result := SB_THUMBTRACK
  else if X < FLen - FCW then
    Result := SB_PAGEDOWN
  else
    Result := SB_LINEDOWN;
end;

{ 获取滚动条滚动的位置 }
procedure TDBScrollBar.GetThumb(rc: TRect);
var
  p   : tpoint;
  size: Integer;
begin
  GetCursorPos(p);
  size := Fthumbbottom - FthumbTop;
  FthumbTop := Ftrackthumb;
  if (FsbDir = sb_Vert) then
    inc(FthumbTop, p.Y - Ftrackp.Y)
  else
    inc(FthumbTop, p.X - Ftrackp.X);

  if FthumbTop < FCW then
    FthumbTop := FCW;
  if FthumbTop > FLen - FCW - size then
    FthumbTop := FLen - FCW - size;
  Fthumbbottom := FthumbTop + size;
end;

{ 隐藏滚动条 }
procedure TDBScrollBar.HideScrollbar;
begin
  ShowWindow(Handle, SW_HIDE);
  FsbVisible := False;
  visible    := False;
end;

{ 重绘 }
procedure TDBScrollBar.Paint;
var
  rc, rc1, rc2: TRect;
  BarInfo     : tagScrollBarInfo;
  sbEnable    : Boolean;
  Temp        : TBitmap;
  bw, sWidth  : Integer;
  b           : Boolean;
begin
  sWidth := 0;

  { 获取滚动条信息 }
  b := False;
  FillChar(BarInfo, sizeof(BarInfo), #0);
  BarInfo.cbSize := sizeof(BarInfo);
  if FsbType = SB_VERT then
    b := GetScrollBarInfo(FhWnd, Integer(OBJID_VSCROLL), BarInfo)
  else if FsbType = SB_HORZ then
    b := GetScrollBarInfo(FhWnd, Integer(OBJID_HSCROLL), BarInfo);
  if not b then
    Exit;

  { 滚动条是否可见 }
  if (BarInfo.rgstate[0] and STATE_SYSTEM_INVISIBLE) > 0 then
    Exit;

  rc := BarInfo.rcScrollBar;
  OffsetRect(rc, -rc.Left, -rc.Top);
  if (rc.Bottom < 0) or (rc.Right < 0) then
    Exit;

  if (rc.Bottom > Height) or (rc.Right > Width) then
    Exit;

  if FsbType = sb_Vert then
    FLen := rc.Bottom
  else
    FLen := rc.Right;

  if abs(sWidth - FCW) > 2 then
    sWidth := FCW;

  Temp        := TBitmap.Create;
  Temp.Width  := rc.Right;
  Temp.Height := rc.Bottom;

  SetStretchBltMode(Temp.Canvas.Handle, STRETCH_DELETESCANS);
  Temp.Canvas.Brush.Color := clWhite;
  Temp.Canvas.Fillrect(rc);

  if FsbType <> SB_CTL then
  begin
    if FsbDir = SB_Horz then
      rc.Bottom := sWidth
    else
      rc.Right  := sWidth;
  end;

  rc1 := rc;
  bw  := FCW;
  if FsbDir = SB_Horz then
  begin
    rc1.Left := rc1.Left + bw;
    rc1.Right := rc1.Right - bw;
    DrawTrackHB(Temp.Canvas, rc1);
  end
  else
  begin
    rc1.Top    := rc1.Top + bw;
    rc1.Bottom := rc1.Bottom - bw;
    DrawTrackVB(Temp.Canvas, rc1);
  end;

  rc1 := rc;
  rc2 := rc;

  if rc.Bottom < 2 * bw then
    bw := rc.Bottom div 2;
  rc1.Bottom := rc1.Top + bw;
  rc2.Top    := rc2.Bottom - bw;

  if (FScrollPos = SB_LINEUP) then
  begin
    if FLButtonDown then
    begin
      if FsbType = SB_VERT then
        DrawArrowUp(Temp.Canvas, rc1, ssClick)
      else
        DrawArrowLeft(Temp.Canvas, rc1, ssClick);
    end
    else
    begin
      if FsbType = SB_VERT then
        DrawArrowUp(Temp.Canvas, rc1, ssHover)
      else
        DrawArrowLeft(Temp.Canvas, rc1, ssHover);
    end;
  end
  else
  begin
    if FsbType = SB_VERT then
      DrawArrowUp(Temp.Canvas, rc1, ssNormal)
    else
      DrawArrowLeft(Temp.Canvas, rc1, ssNormal);
  end;

  if (FScrollPos = SB_LINEDOWN) then
  begin
    if FLButtonDown then
    begin
      if FsbType = SB_VERT then
        DrawArrowDown(Temp.Canvas, rc2, ssClick)
      else
        DrawArrowRight(Temp.Canvas, rc2, ssClick);
    end
    else
    begin
      if FsbType = SB_VERT then
        DrawArrowDown(Temp.Canvas, rc2, ssHover)
      else
        DrawArrowRight(Temp.Canvas, rc2, ssHover);
    end;
  end
  else
  begin
    if FsbType = SB_VERT then
      DrawArrowDown(Temp.Canvas, rc2, ssNormal)
    else
      DrawArrowRight(Temp.Canvas, rc2, ssNormal);
  end;

  FthumbTop := BarInfo.xyThumbTop;
  Fthumbbottom := BarInfo.xyThumbBottom;
  sbEnable := (BarInfo.rgstate[0] and STATE_SYSTEM_UNAVAILABLE) = 0;
  if sbEnable then
  begin
    if (FsbDir = sb_Vert) then
    begin
      rc1 := Rect(0, FthumbTop, sWidth, Fthumbbottom);
      if (FthumbTop < Height) and (Fthumbbottom < Height) then
      begin
        if (FScrollPos = SB_THUMBTRACK) then
        begin
          if FLButtonDown then
            DrawThumbVB(Temp.Canvas, rc1, ssClick)
          else
          begin
            if (rc1.Top = FCW - 1) and (rc1.Bottom = Height - FCW - 1) then
            begin

            end
            else
            begin
              DrawThumbVB(Temp.Canvas, rc1, ssHover);
            end;
          end;
        end
        else
        begin
          if (rc1.Top = FCW - 1) and (rc1.Bottom = Height - FCW - 1) then
          begin

          end
          else
          begin
            if (rc1.Bottom <> 2 * FCW - 1) then
              DrawThumbVB(Temp.Canvas, rc1, ssNormal);
          end;
        end;
      end;
    end;

    if FsbType = SB_HORZ then
    begin
      rc1:=Rect(FthumbTop, 0, Fthumbbottom, swidth);
      if (Fthumbtop < Width) and (Fthumbbottom < Width) then
      begin
        if (FScrollPos = SB_THUMBTRACK) then
        begin
          if FLButtonDown then
            DrawThumbHB(Temp.Canvas, rc1, ssClick)
          else
          begin
            if (rc1.Left = FCW - 1) and (rc1.Right = Width - FCW - 1) then
            begin

            end
            else
            begin
              DrawThumbHB(Temp.Canvas, rc1, ssHover);
            end;
          end;
        end
        else
        begin
          if (rc1.Left = FCW - 1) and (rc1.Right = Width - FCW - 1) then
          begin

          end
          else
          begin
            if (rc1.Bottom <> 2 * FCW - 1) then
              DrawThumbHB(Temp.Canvas, rc1, ssNormal);
          end;
        end;
      end;
    end;
  end;

  rc := ClientRect;
  StretchBlt(Canvas.Handle, 0, 0, Temp.Width, Temp.Height, Temp.Canvas.Handle, 0, 0, Temp.Width, Temp.Height, SRCCOPY);
  Temp.Free;
end;

procedure TDBScrollBar.SetPosition(ahWnd: THandle);
var
  parenthWnd, prehWnd : THandle;
  r1                  : TRect;
  p                   : tpoint;
  BarInfo             : tagScrollBarInfo;
  b                   : Boolean;
  dw                  : dword;
begin
  FhWnd           := ahWnd;
  parenthWnd      := GetParent(FhWnd);
  FillChar(BarInfo, sizeof(BarInfo), #0);
  BarInfo.cbSize  := sizeof(BarInfo);
  FsbVisible      := True;
  b               := False;

  if FsbType = sb_Vert then
    b := GetScrollBarInfo(FhWnd, Integer(OBJID_VSCROLL), BarInfo)
  else if FsbType = SB_HORZ then
    b := GetScrollBarInfo(FhWnd, Integer(OBJID_HSCROLL), BarInfo);

  FsbVisible := b;

  if not b then
    Exit;

  dw := GetWindowLong(FhWnd, GWL_STYLE);
  if (dw and ws_visible) = 0 then
  begin
    FsbVisible := False;
    ShowWindow(Handle, SW_HIDE);
    Exit;
  end;

  if ((BarInfo.rgstate[0] and STATE_SYSTEM_INVISIBLE) > 0) then
  begin
    if FsbDir = sb_Vert then
      ShowWindow(Handle, SW_HIDE)
    else
      ShowWindow(Handle, SW_HIDE);

    FsbVisible := False;
  end
  else
  begin
    r1  := BarInfo.rcScrollBar;
    p   := r1.TopLeft;
    Windows.screentoclient(FhWnd, p);
    FsbRect.TopLeft := p;
    p := r1.BottomRight;
    Windows.screentoclient(FhWnd, p);
    FsbRect.BottomRight := p;

    OffsetRect(r1, -r1.Left, -r1.Top);
    if FsbDir = sb_Vert then
      FLen := r1.Bottom
    else
      FLen := r1.Right;

    p := Point(BarInfo.rcScrollBar.Left, BarInfo.rcScrollBar.Top);
    FOffsetSC := p;
    Windows.screentoclient(parenthWnd, p);

    prehWnd := GetNextWindow(FhWnd, GW_hWndPREV);
    if prehWnd = 0 then
      prehWnd := hWnd_TOP;
    ShowWindow(Handle, SW_Show);
    FsbVisible := True;

    SetWindowPos(Handle, prehWnd, p.X, p.Y, r1.Right, r1.Bottom, 0); // SWP_NOREDRAW);
    MoveWindow(Handle, p.X, p.Y, r1.Right, r1.Bottom, True);
  end;
end;

procedure TDBScrollBar.WMERASEBKGND(var Msg: TMessage);
begin
  Msg.Result := 1;
end;

procedure TDBScrollBar.WMLButtonDBClick(var aMsg: TMessage);
begin
  WMLButtonDown(aMsg);
end;

procedure TDBScrollBar.WMLButtonDown(var aMsg: TMessage);
var
  pt      : tpoint;
  BarInfo : tagScrollBarInfo;
begin
  inherited;
  pt := Point(aMsg.LParamLo, aMsg.LParamhi);
  GetCursorPos(Ftrackp);
  FillChar(BarInfo, sizeof(BarInfo), #0);
  BarInfo.cbSize := sizeof(BarInfo);

  if FsbType = SB_HORZ then
  begin
    if GetScrollBarInfo(FhWnd, Integer(OBJID_HSCROLL), BarInfo) then
      Ftrackthumb := BarInfo.xyThumbTop;
  end
  else if FsbType = SB_VERT then
  begin
    if GetScrollBarInfo(FhWnd, Integer(OBJID_VSCROLL), BarInfo) then
      Ftrackthumb := BarInfo.xyThumbTop;
  end;

  FScrollPos := GetScrollPos(pt);

  FOffsetSC     := Point(BarInfo.rcScrollBar.Left, BarInfo.rcScrollBar.Top);
  aMsg.LParamLo := aMsg.LParamLo + FOffsetSC.X; // inc(amsg.LParamLo,offsetSc.x);
  aMsg.LParamhi := aMsg.LParamhi + FOffsetSC.Y; // inc(amsg.LParamHi,offsetSc.y);

  FLButtonDown := True;
  Invalidate;
  FScrollPos := GetScrollPos(pt);
  ReleaseCapture;

  if FsbType = sb_Vert then
    PostMessage(FhWnd, WM_NCLBUTTONDOWN, HTVSCROLL, aMsg.lparam)
  else if FsbType = SB_HORZ then
    PostMessage(FhWnd, WM_NCLBUTTONDOWN, HTHSCROLL, aMsg.lparam);

  FLButtonDown := False;
  ReleaseCapture;
end;

procedure TDBScrollBar.WMLButtonUp(var aMsg: TMessage);
begin
  inherited;

  FLButtonDown := False;
  ReleaseCapture;

  if FsbType = SB_VERT  then
    PostMessage(FhWnd, WM_NCLBUTTONUP, HTVSCROLL, aMsg.lparam)
  else
    PostMessage(FhWnd, WM_NCLBUTTONUP, HTHSCROLL, aMsg.lparam);
end;

procedure TDBScrollBar.WMMouseLeave(var aMsg: TMessage);
begin
  if not FLButtonDown then
  begin
    FScrollPos := -1;
    Invalidate;
  end;
end;

procedure TDBScrollBar.WMMouseMove(var aMsg: TMessage);
var
  ptMouse: tpoint;
  iPos: Integer;
begin
  inherited;
  PostMessage(FhWnd, WM_NCMOUSEMOVE, HTVSCROLL, aMsg.lparam);
  ptMouse := Point(aMsg.LParamLo, aMsg.LParamhi);
  iPos := GetScrollPos(ptMouse);
  if iPos <> FScrollPos then
  begin
    FScrollPos := iPos;
    Invalidate;
  end;
end;

{ TFMScrollBar }

procedure TFMScrollBar.AfterProc(var Message: TMessage);
begin
  case message.Msg of
    CM_VISIBLECHANGED:
      begin
        if message.WParam = 0 then
        begin
          Fvb.HideScrollbar;
          Fhb.HideScrollbar;
        end
        else
          SetScrollbarPos(message);
      end;
    CM_ENABLEDCHANGED:
      begin
        Fvb.Enabled := FControl.Enabled;
        Fhb.Enabled := FControl.Enabled;
      end;
    CM_RECREATEWND:
      begin
      end;
    WM_Size, WM_WINDOWPOSCHANGED:
      begin
        SetScrollbarPos(message);
      end;
    WM_VSCROLL:
      begin
        Fvb.FScrollPos := message.WParamLo;
        Fvb.Invalidate;
      end;
    WM_HSCROLL:
      begin
        Fhb.FScrollPos := message.WParamLo;
        Fhb.Invalidate;
      end;
    WM_MOUSEWHEEL:
      begin
        if (Fvb <> nil) and Fvb.FsbVisible then Fvb.Invalidate;
        if (Fhb <> nil) and Fhb.FsbVisible then Fhb.Invalidate;
      end;
  else
    inherited AfterProc(message);
  end;
end;

constructor TFMScrollBar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  Fvb := nil;
  Fhb := nil;
end;

destructor TFMScrollBar.Destroy;
begin
  if Fvb <> nil then Fvb.Free;
  Fvb := nil;

  if Fhb <> nil then Fhb.free;
  Fhb:=nil;

  inherited;
end;

procedure TFMScrollBar.DrawControl(dc: HDC; rc: TRect);
var
  Style: DWORD;
  r    : TRect;
begin
  Style := GetWindowLong(FhWnd, GWL_STYLE);
  if Fvb <> nil then
  begin
    if Fvb.FsbVisible then
      Fvb.Invalidate
    else if (Style and WS_VSCROLL) > 0 then
      Fvb.SetPosition(FhWnd);
  end;

  if (Fhb<>nil) then
  begin
    if Fhb.visible then
      Fhb.Invalidate
    else if (Style and WS_HSCROLL) > 0 then
      Fhb.SetPosition(FhWnd);
  end;

  if (Fvb <> nil) and (Fhb <> nil) and Fvb.Fsbvisible and Fhb.Fsbvisible then
  begin
    r := rect(Fvb.FsbRect.left + 2, Fhb.FsbRect.top + 2, Fvb.FsbRect.right + 2, Fhb.FsbRect.bottom + 2);
    FillBG(dc,r);
  end;

end;

procedure TFMScrollBar.InitScrollbar(aControl: TWincontrol);
begin
  FControl := aControl;
  FhWnd := FControl.Handle;

  Fvb := TDBScrollBar.Create(Self);
  Fvb.Attach(FControl, sb_Vert);
  Fvb.Enabled := FControl.Enabled;

  Fhb := TDBScrollBar.Create(Self);
  Fhb.Attach(FControl, SB_HORZ);
  Fhb.Enabled := FControl.Enabled;

  if not FControl.visible then
    Fvb.HideScrollbar;

  FOldWndProc         := FControl.WindowProc;
  FControl.WindowProc := NewWndProc;
end;

procedure TFMScrollBar.SetScrollbarPos(Message: TMessage);
begin
  if Fvb <> nil then Fvb.SetPosition(FhWnd);
  if Fhb <> nil then Fhb.SetPosition(FhWnd);
end;

initialization
  PngSB := TPngImage.Create;
  PngSB.LoadFromResourceName(HInstance, 'RES_SCROLLBAR');

finalization
  PngSB.Free;

end.
