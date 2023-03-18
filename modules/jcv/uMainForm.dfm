object frmOpenCV: TfrmOpenCV
  Left = 0
  Top = 0
  Caption = 'JavaCV V2.0'
  ClientHeight = 696
  ClientWidth = 1156
  Color = clBtnFace
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poScreenCenter
  OnActivate = FormActivate
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 13
  object img1: TImage
    Left = 0
    Top = 0
    Width = 681
    Height = 696
    Align = alClient
    Stretch = True
    ExplicitLeft = 36
    ExplicitTop = 124
    ExplicitWidth = 105
    ExplicitHeight = 105
  end
  object spl1: TSplitter
    Left = 681
    Top = 0
    Height = 696
    Align = alRight
    ExplicitLeft = 584
    ExplicitTop = 316
    ExplicitHeight = 100
  end
  object mmoLOG: TMemo
    Left = 684
    Top = 0
    Width = 472
    Height = 696
    Align = alRight
    Font.Charset = GB2312_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = #23435#20307
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 0
    ExplicitLeft = 680
    ExplicitHeight = 695
  end
end
