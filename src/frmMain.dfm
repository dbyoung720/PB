object frmPBox: TfrmPBox
  Left = 0
  Top = 0
  Caption = 'frmPBox'
  ClientHeight = 671
  ClientWidth = 1049
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnActivate = FormActivate
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  TextHeight = 15
  object clbrPModule: TCoolBar
    Left = 0
    Top = 0
    Width = 1049
    Height = 24
    AutoSize = True
    BandBorderStyle = bsNone
    Bands = <
      item
        Control = tlbMenu
        ImageIndex = -1
        MinHeight = 24
        Width = 1047
      end>
    EdgeInner = esNone
    EdgeOuter = esNone
    FixedOrder = True
    ExplicitWidth = 1045
    object tlbMenu: TToolBar
      Left = 2
      Top = 0
      Width = 1047
      Height = 24
      ButtonHeight = 38
      ButtonWidth = 43
      Caption = 'tlbMenu'
      Font.Charset = GB2312_CHARSET
      Font.Color = clWindowText
      Font.Height = -14
      Font.Name = #23435#20307
      Font.Style = []
      ParentFont = False
      ShowCaptions = True
      TabOrder = 0
    end
  end
  object pgcAll: TPageControl
    Left = 0
    Top = 24
    Width = 1049
    Height = 647
    ActivePage = tsWelcome
    Align = alClient
    DoubleBuffered = True
    ParentDoubleBuffered = False
    Style = tsFlatButtons
    TabOrder = 1
    ExplicitWidth = 1045
    ExplicitHeight = 646
    object tsWelcome: TTabSheet
      Caption = 'tsWelcome'
      ImageIndex = 4
    end
    object tsButton: TTabSheet
      Caption = 'tsButton'
      object pnlModuleDialog: TPanel
        Left = 215
        Top = 104
        Width = 654
        Height = 385
        BevelOuter = bvNone
        BorderStyle = bsSingle
        Caption = 'pnlModuleDialog'
        Color = clWhite
        Ctl3D = False
        ParentBackground = False
        ParentCtl3D = False
        ShowCaption = False
        TabOrder = 0
        object pnlModuleDialogTitle: TPanel
          Left = 0
          Top = 0
          Width = 652
          Height = 45
          Align = alTop
          Caption = 'pnlModuleDialogTitle'
          Color = 9916930
          Font.Charset = GB2312_CHARSET
          Font.Color = clWhite
          Font.Height = -16
          Font.Name = #24494#36719#38597#40657
          Font.Style = [fsBold]
          ParentBackground = False
          ParentFont = False
          TabOrder = 0
          DesignSize = (
            652
            45)
          object imgSubModuleClose: TImage
            Left = 616
            Top = 7
            Width = 32
            Height = 32
            Anchors = [akTop, akRight]
            Transparent = True
            OnClick = imgSubModuleCloseClick
            OnMouseEnter = imgSubModuleCloseMouseEnter
            OnMouseLeave = imgSubModuleCloseMouseLeave
          end
        end
      end
    end
    object tsList: TTabSheet
      Caption = 'tsList'
      ImageIndex = 3
      object ctgrypnlgrpModule: TCategoryPanelGroup
        Left = 0
        Top = 0
        Height = 614
        VertScrollBar.Tracking = True
        Color = clWhite
        HeaderFont.Charset = DEFAULT_CHARSET
        HeaderFont.Color = clWindowText
        HeaderFont.Height = -11
        HeaderFont.Name = 'Tahoma'
        HeaderFont.Style = []
        TabOrder = 0
      end
    end
    object tsCenter: TTabSheet
      Caption = 'tsCenter'
      ImageIndex = 1
    end
    object tsDll: TTabSheet
      Caption = 'tsDll'
      ImageIndex = 2
    end
  end
  object pmTray: TPopupMenu
    AutoHotkeys = maManual
    Left = 532
    Top = 85
    object mniFuncMenuConfig: TMenuItem
      Caption = #37197#32622
      OnClick = mniFuncMenuConfigClick
    end
    object mniFuncMenuMoney: TMenuItem
      Caption = #25424#21161
      OnClick = mniFuncMenuMoneyClick
    end
    object mniFuncMenuLine01: TMenuItem
      Caption = '-'
    end
    object mniFuncMenuAbout: TMenuItem
      Caption = #20851#20110
      OnClick = mniFuncMenuAboutClick
    end
  end
  object mmMainMenu: TMainMenu
    AutoHotkeys = maManual
    AutoMerge = True
    Images = ilMainMenu
    Left = 620
    Top = 85
  end
  object ilMainMenu: TImageList
    ColorDepth = cd32Bit
    Height = 32
    Width = 32
    Left = 356
    Top = 85
  end
  object ilPModule: TImageList
    ColorDepth = cd32Bit
    Height = 32
    Width = 32
    Left = 444
    Top = 85
  end
end
