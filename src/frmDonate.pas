unit frmDonate;

interface

uses
  System.Classes, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Imaging.pngimage;

type
  TfrmDonate = class(TForm)
    lbl1: TLabel;
    img1: TImage;
    img2: TImage;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

procedure ShowDonateForm;

implementation

{$R *.dfm}

procedure ShowDonateForm;
begin
  with TfrmDonate.Create(nil) do
  begin
    Position := poScreenCenter;
    ShowModal;
    Free;
  end;
end;

end.
