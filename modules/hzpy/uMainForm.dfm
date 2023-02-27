object frmHZPY: TfrmHZPY
  Left = 0
  Top = 0
  Caption = #33719#21462#27721#23383#25340#38899
  ClientHeight = 567
  ClientWidth = 1045
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  Position = poScreenCenter
  DesignSize = (
    1045
    567)
  PixelsPerInch = 96
  TextHeight = 13
  object Label4: TLabel
    Left = 8
    Top = 8
    Width = 64
    Height = 16
    Caption = #23383#31526#20018' :'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = #23435#20307
    Font.Style = []
    ParentFont = False
  end
  object Label5: TLabel
    Left = 528
    Top = 8
    Width = 72
    Height = 16
    Caption = #27721#23383#25340#38899':'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = #23435#20307
    Font.Style = []
    ParentFont = False
  end
  object Memo1: TMemo
    Left = 8
    Top = 30
    Width = 514
    Height = 529
    Anchors = [akLeft, akTop, akBottom]
    Font.Charset = GB2312_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = #23435#20307
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 0
  end
  object Memo2: TMemo
    Left = 528
    Top = 30
    Width = 513
    Height = 529
    Anchors = [akLeft, akTop, akRight, akBottom]
    Font.Charset = GB2312_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = #23435#20307
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 1
  end
  object MainMenu1: TMainMenu
    AutoHotkeys = maManual
    Left = 600
    Top = 348
    object mnuFile: TMenuItem
      Caption = #25991#20214
      object mnuFileOpen: TMenuItem
        Caption = #25171#24320
        OnClick = mnuFileOpenClick
      end
    end
    object mnuPY: TMenuItem
      Caption = #25340#38899
      object mnuPYHZ: TMenuItem
        Caption = #27721#23383#25340#38899
        OnClick = mnuPYHZClick
      end
      object mnuPYHead: TMenuItem
        Caption = #27721#23383#25340#38899#39318#23383#27597
        OnClick = mnuPYHeadClick
      end
    end
  end
  object OpenDialog1: TOpenDialog
    Left = 600
    Top = 292
  end
end
