object frmConfig: TfrmConfig
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = #37197#32622
  ClientHeight = 489
  ClientWidth = 832
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poDesigned
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  DesignSize = (
    832
    489)
  TextHeight = 13
  object lbl2: TLabel
    Left = 8
    Top = 274
    Width = 70
    Height = 19
    Caption = #26174#31034#39118#26684#65306
    Font.Charset = GB2312_CHARSET
    Font.Color = clRed
    Font.Height = -14
    Font.Name = #24494#36719#38597#40657
    Font.Style = [fsBold]
    ParentFont = False
  end
  object lbl3: TLabel
    Left = 354
    Top = 5
    Width = 126
    Height = 19
    Caption = #27169#22359#26174#31034#39034#24207#35843#25972#65306
    Font.Charset = GB2312_CHARSET
    Font.Color = clRed
    Font.Height = -14
    Font.Name = #24494#36719#38597#40657
    Font.Style = [fsBold]
    ParentFont = False
  end
  object lbl1: TLabel
    Left = 8
    Top = 5
    Width = 70
    Height = 19
    Caption = #30028#38754#26174#31034#65306
    Font.Charset = GB2312_CHARSET
    Font.Color = clRed
    Font.Height = -14
    Font.Name = #24494#36719#38597#40657
    Font.Style = [fsBold]
    ParentFont = False
  end
  object btnDatabaseConfig: TSpeedButton
    Left = 8
    Top = 445
    Width = 92
    Height = 36
    Anchors = [akLeft, akBottom]
    Caption = #25968#25454#24211#37197#32622
    Font.Charset = GB2312_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = #23435#20307
    Font.Style = []
    ParentFont = False
    OnClick = btnDatabaseConfigClick
    ExplicitTop = 511
  end
  object grpUI: TGroupBox
    Left = 8
    Top = 25
    Width = 333
    Height = 232
    Font.Charset = GB2312_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = #23435#20307
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    object lblTitle: TLabel
      Left = 10
      Top = 12
      Width = 105
      Height = 15
      Caption = #26631#39064#25991#26412#26174#31034#65306
    end
    object edtTitle: TEdit
      Left = 10
      Top = 33
      Width = 303
      Height = 23
      TabOrder = 0
    end
    object chkTopForm: TCheckBox
      Left = 10
      Top = 64
      Width = 224
      Height = 17
      Caption = #31383#20307#20445#25345#39030#31471#26174#31034
      TabOrder = 1
    end
    object chkCloseMini: TCheckBox
      Left = 10
      Top = 117
      Width = 224
      Height = 17
      Caption = #20851#38381#26102#65292#26368#23567#21270#21040#25176#30424#21306
      TabOrder = 3
    end
    object chkAutorun: TCheckBox
      Left = 10
      Top = 143
      Width = 224
      Height = 17
      Caption = #24320#26426#33258#21160#21551#21160
      TabOrder = 4
    end
    object chkOnlyOneInstance: TCheckBox
      Left = 10
      Top = 170
      Width = 224
      Height = 17
      Caption = #21482#20801#35768#36816#34892#19968#20010#23454#20363
      TabOrder = 5
    end
    object chkFullScreen: TCheckBox
      Left = 10
      Top = 91
      Width = 224
      Height = 17
      Caption = #31383#20307#26368#22823#21270#26174#31034
      TabOrder = 2
    end
    object chkLoadSpeed: TCheckBox
      Left = 10
      Top = 197
      Width = 143
      Height = 17
      Caption = #20248#21270#27169#22359#21152#36733#36895#24230
      TabOrder = 6
      OnClick = chkLoadSpeedClick
    end
  end
  object btnSave: TButton
    Left = 727
    Top = 445
    Width = 92
    Height = 36
    Anchors = [akRight, akBottom]
    Caption = #20445#23384
    Font.Charset = GB2312_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = #23435#20307
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    OnClick = btnSaveClick
  end
  object btnCancel: TButton
    Left = 611
    Top = 445
    Width = 92
    Height = 36
    Anchors = [akRight, akBottom]
    Caption = #21462#28040
    Font.Charset = GB2312_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = #23435#20307
    Font.Style = []
    ParentFont = False
    TabOrder = 2
    OnClick = btnCancelClick
  end
  object rgShowStyle: TRadioGroup
    Left = 8
    Top = 300
    Width = 333
    Height = 132
    Font.Charset = GB2312_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = #23435#20307
    Font.Style = []
    ItemIndex = 0
    Items.Strings = (
      #33756#21333#39118#26684
      #25353#38062#39118#26684
      #21015#34920#39118#26684
      #20013#24515#39118#26684)
    ParentFont = False
    TabOrder = 3
    OnClick = rgShowStyleClick
  end
  object grpModuleSort: TGroupBox
    Left = 352
    Top = 25
    Width = 467
    Height = 407
    Anchors = [akLeft, akTop, akBottom]
    Color = clBtnFace
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentBackground = False
    ParentColor = False
    ParentFont = False
    TabOrder = 4
    ExplicitHeight = 422
    DesignSize = (
      467
      407)
    object imgPModuleIcon: TImage
      Left = 183
      Top = 114
      Width = 32
      Height = 32
      Cursor = crHandPoint
      ParentShowHint = False
      ShowHint = False
      Stretch = True
      OnClick = imgPModuleIconClick
    end
    object imgSModuleIcon: TImage
      Left = 420
      Top = 114
      Width = 32
      Height = 32
      Cursor = crHandPoint
      ParentShowHint = False
      ShowHint = False
      Stretch = True
      OnClick = imgSModuleIconClick
    end
    object lblPModule: TLabel
      Left = 20
      Top = 1
      Width = 84
      Height = 20
      Caption = #29238#27169#22359#21015#34920#65306
      Font.Charset = GB2312_CHARSET
      Font.Color = clBlue
      Font.Height = -14
      Font.Name = #24494#36719#38597#40657
      Font.Style = []
      ParentFont = False
    end
    object lblSModule: TLabel
      Left = 265
      Top = 1
      Width = 84
      Height = 20
      Caption = #23376#27169#22359#21015#34920#65306
      Font.Charset = GB2312_CHARSET
      Font.Color = clBlue
      Font.Height = -14
      Font.Name = #24494#36719#38597#40657
      Font.Style = []
      ParentFont = False
    end
    object lstParentModule: TListBox
      Left = 20
      Top = 21
      Width = 149
      Height = 369
      Anchors = [akLeft, akTop, akBottom]
      Font.Charset = GB2312_CHARSET
      Font.Color = clBlack
      Font.Height = -15
      Font.Name = #23435#20307
      Font.Style = []
      ItemHeight = 15
      ParentFont = False
      TabOrder = 0
      OnClick = lstParentModuleClick
      ExplicitHeight = 384
    end
    object lstSubModule: TListBox
      Left = 264
      Top = 21
      Width = 141
      Height = 369
      Anchors = [akLeft, akTop, akBottom]
      Font.Charset = GB2312_CHARSET
      Font.Color = clBlack
      Font.Height = -15
      Font.Name = #23435#20307
      Font.Style = []
      ItemHeight = 15
      ParentFont = False
      TabOrder = 1
      OnClick = lstSubModuleClick
      ExplicitHeight = 384
    end
    object btnParentUp: TButton
      Left = 174
      Top = 21
      Width = 53
      Height = 25
      Caption = #19978#31227#8593
      TabOrder = 2
      OnClick = btnParentUpClick
    end
    object btnParentDown: TButton
      Left = 174
      Top = 47
      Width = 53
      Height = 25
      Caption = #19979#31227#8595
      TabOrder = 3
      OnClick = btnParentDownClick
    end
    object btnSubUp: TButton
      Left = 409
      Top = 21
      Width = 53
      Height = 25
      Caption = #19978#31227#8593
      TabOrder = 4
      OnClick = btnSubUpClick
    end
    object btnSubDown: TButton
      Left = 409
      Top = 47
      Width = 53
      Height = 25
      Caption = #19979#31227#8595
      TabOrder = 5
      OnClick = btnSubDownClick
    end
    object btnSubModuleIcon: TButton
      Left = 409
      Top = 72
      Width = 53
      Height = 25
      Hint = #36873#25321#22270#26631#65292#24517#39035#26159' 32'#215'32 '#30340' ico '#22270#29255
      Anchors = [akRight, akBottom]
      Caption = #22270#26631
      ParentShowHint = False
      ShowHint = True
      TabOrder = 6
      OnClick = imgSModuleIconClick
      ExplicitTop = 87
    end
    object chkGray: TCheckBox
      Left = 414
      Top = 259
      Width = 97
      Height = 17
      Anchors = [akRight, akBottom]
      Caption = #38544#34255
      TabOrder = 7
      Visible = False
      ExplicitTop = 274
    end
    object btnPModuleIcon: TButton
      Left = 174
      Top = 72
      Width = 53
      Height = 25
      Hint = #36873#25321#22270#26631#65292#24517#39035#26159' 32'#215'32 '#30340' ico '#22270#29255
      Anchors = [akRight, akBottom]
      Caption = #22270#26631
      ParentShowHint = False
      ShowHint = True
      TabOrder = 8
      OnClick = imgPModuleIconClick
      ExplicitTop = 87
    end
    object btnAddEXE: TButton
      Left = 409
      Top = 365
      Width = 53
      Height = 25
      Hint = #24517#39035#26159' 32'#215'32 '#30340' bmp,ico,png '#22270#29255
      Anchors = [akRight, akBottom]
      Caption = #28155#21152'EXE'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 9
      OnClick = btnAddEXEClick
      ExplicitTop = 380
    end
  end
  object chkShowCloseButton: TCheckBox
    Left = 156
    Top = 366
    Width = 165
    Height = 18
    Caption = #26174#31034'Dll'#31383#20307#20851#38381#25353#38062
    Font.Charset = GB2312_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = #23435#20307
    Font.Style = []
    ParentFont = False
    TabOrder = 5
  end
  object OpenPictureDialog1: TOpenPictureDialog
    Left = 408
    Top = 225
  end
end
