unit uFullScreen;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uCommon;

type
  TfrmFullScreen = class(TForm)
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    Fcvs          : TCanvas;
    FbMouseDown   : Boolean;
    FptOld        : TPoint;
    Fpt1, Fpt2    : TPoint;
    FbShowMainForm: Boolean;
    procedure DrawRect(const pt1, pt2: TPoint);
    procedure DeleteRect;
  end;

procedure ShowFullScreen(DllMainFormHandle: THandle; const bShowMainForm: Boolean = True);

implementation

{$R *.dfm}

uses uMain;

var
  frmFullScreen: TfrmFullScreen = nil;
  FDllMainForm : TfrmSnapScreen;

procedure ShowFullScreen(DllMainFormHandle: THandle; const bShowMainForm: Boolean = True);
begin
  FDllMainForm := TfrmSnapScreen(GetInstanceFromhWnd(DllMainFormHandle));

  frmFullScreen := TfrmFullScreen.Create(nil);
  with frmFullScreen do
  begin
    FbMouseDown    := False;
    Fcvs           := TCanvas.Create;
    Fcvs.Handle    := GetDC(0);
    Fpt1.X         := 0;
    Fpt1.Y         := 0;
    Fpt2.X         := 0;
    Fpt2.Y         := 0;
    Top            := 0;
    Left           := 0;
    Width          := Screen.DesktopWidth;
    Height         := Screen.DesktopHeight;
    FbShowMainForm := bShowMainForm;
    // FormStyle    := fsStayOnTop;
    Show;
  end;
end;

procedure TfrmFullScreen.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  DeleteDC(Fcvs.Handle);
  Fcvs.Free;
  Action := caFree;
end;

procedure TfrmFullScreen.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = Char(VK_ESCAPE) then
  begin
    Close;
    FDllMainForm.ShowMainForm;
  end;
end;

procedure TfrmFullScreen.FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FbMouseDown := True;
  GetCursorPos(FptOld);
end;

procedure TfrmFullScreen.FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  pt: TPoint;
begin
  if not FbMouseDown then
    Exit;

  GetCursorPos(pt);
  DrawRect(FptOld, pt);
end;

procedure TfrmFullScreen.FormMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  pt: TPoint;
begin
  FbMouseDown := False;
  GetCursorPos(pt);
  DrawRect(FptOld, pt);

  Hide;
  Close;
  FDllMainForm.Snap(FptOld.X, FptOld.Y, pt.X, pt.Y);
  FDllMainForm.ShowMainForm(FbShowMainForm);
end;

procedure TfrmFullScreen.DeleteRect;
var
  rgn1, rgn2: THandle;
begin
  rgn1 := CreateRectRgn(0, 0, Width, Height);
  rgn2 := CreateRectRgn(Fpt1.X, Fpt1.Y, Fpt2.X, Fpt2.Y);
  CombineRGN(rgn1, rgn1, rgn2, RGN_XOR);
  SetWindowRgn(Handle, rgn1, False);
  DeleteObject(rgn1);
  DeleteObject(rgn2);
end;

procedure TfrmFullScreen.DrawRect(const pt1, pt2: TPoint);
begin
  if (Fpt1.X = pt1.X) and (Fpt1.Y = pt1.Y) and (Fpt2.X = pt2.X) and (Fpt2.Y = pt2.Y) then
    Exit;

  { Ñ¡Ôñ½ØÍ¼ÇøÓò }
  Fpt1 := pt1;
  Fpt2 := pt2;
  DeleteRect;

  { »­ºìÉ«Íâ¿ò }
  Fcvs.pen.Color   := clRed;
  Fcvs.pen.Width   := 2;
  Fcvs.brush.Style := bsClear;
  Fcvs.Rectangle(pt1.X + 1, pt1.Y + 1, pt2.X - 1, pt2.Y - 1);
end;

end.
