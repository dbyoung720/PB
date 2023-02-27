object frmtxtOCR: TfrmtxtOCR
  Left = 0
  Top = 0
  Caption = #25991#23383#35782#21035'/'#36710#29260#35782#21035'/'#36523#20221#35777#35782#21035' v2.0'
  ClientHeight = 700
  ClientWidth = 935
  Color = clBtnFace
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  DesignSize = (
    935
    700)
  PixelsPerInch = 96
  TextHeight = 13
  object imgShow: TImage
    Left = 16
    Top = 35
    Width = 897
    Height = 358
    Anchors = [akLeft, akTop, akRight, akBottom]
    Stretch = True
  end
  object srchbxFile: TSearchBox
    Left = 16
    Top = 8
    Width = 897
    Height = 21
    Hint = #25171#24320#22270#29255#25991#20214
    Anchors = [akLeft, akTop, akRight]
    ParentShowHint = False
    ReadOnly = True
    ShowHint = True
    TabOrder = 0
    OnInvokeSearch = srchbxFileInvokeSearch
  end
  object grpText: TGroupBox
    Left = 16
    Top = 408
    Width = 897
    Height = 284
    Anchors = [akLeft, akRight, akBottom]
    Caption = #35782#21035#32467#26524#65306
    TabOrder = 1
    Visible = False
    object mmoText: TMemo
      Left = 2
      Top = 15
      Width = 893
      Height = 267
      Align = alClient
      BorderStyle = bsNone
      Font.Charset = GB2312_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = #23435#20307
      Font.Style = []
      ParentFont = False
      ReadOnly = True
      ScrollBars = ssBoth
      TabOrder = 0
    end
  end
  object dlgOpenPic1: TOpenPictureDialog
    Left = 248
    Top = 64
  end
end
