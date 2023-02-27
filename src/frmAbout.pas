unit frmAbout;

interface

uses
  Winapi.Windows, Winapi.ShellAPI, System.Classes, Vcl.Forms, Vcl.StdCtrls, Vcl.Controls;

type
  TfrmAbout = class(TForm)
    lbl1: TLabel;
    lbl2: TLabel;
    lbl3: TLabel;
    lbl4: TLabel;
    lbl5: TLabel;
    lbl6: TLabel;
    lbl7: TLabel;
    lbl8: TLabel;
    lbl9: TLabel;
    lbl10: TLabel;
    lbl11: TLabel;
    lbl12: TLabel;
    lbl13: TLabel;
    lbl14: TLabel;
    procedure lbl12Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

procedure ShowAboutForm;

implementation

{$R *.dfm}

procedure ShowAboutForm;
begin
  with TfrmAbout.Create(nil) do
  begin
    Position := poScreenCenter;
    ShowModal;
    Free;
  end;
end;

procedure TfrmAbout.lbl12Click(Sender: TObject);
begin
  ShellExecute(0, 'open', PChar(TLabel(Sender).Caption), nil, nil, 1);
  Close;
end;

end.
