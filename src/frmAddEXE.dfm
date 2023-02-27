object frmAddEXE: TfrmAddEXE
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = #28155#21152' EXE '
  ClientHeight = 226
  ClientWidth = 411
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  DesignSize = (
    411
    226)
  PixelsPerInch = 96
  TextHeight = 13
  object lbl1: TLabel
    Left = 8
    Top = 49
    Width = 106
    Height = 15
    Caption = #29238#27169#22359#21517#31216'  '#65306
    Font.Charset = GB2312_CHARSET
    Font.Color = clRed
    Font.Height = -15
    Font.Name = #23435#20307
    Font.Style = []
    ParentFont = False
  end
  object lbl2: TLabel
    Left = 8
    Top = 83
    Width = 106
    Height = 15
    Caption = #23376#27169#22359#21517#31216'  '#65306
    Font.Charset = GB2312_CHARSET
    Font.Color = clRed
    Font.Height = -15
    Font.Name = #23435#20307
    Font.Style = []
    ParentFont = False
  end
  object lbl3: TLabel
    Left = 8
    Top = 117
    Width = 106
    Height = 15
    Caption = #20027#31383#20307#31867#21517'  '#65306
    Font.Charset = GB2312_CHARSET
    Font.Color = clRed
    Font.Height = -15
    Font.Name = #23435#20307
    Font.Style = []
    ParentFont = False
  end
  object lbl4: TLabel
    Left = 8
    Top = 151
    Width = 105
    Height = 15
    Caption = #20027#31383#20307#26631#39064#21517#65306
    Font.Charset = GB2312_CHARSET
    Font.Color = clRed
    Font.Height = -15
    Font.Name = #23435#20307
    Font.Style = []
    ParentFont = False
  end
  object lbl5: TLabel
    Left = 8
    Top = 16
    Width = 107
    Height = 15
    Caption = 'EXE'#25991#20214#21517#31216' '#65306
    Font.Charset = GB2312_CHARSET
    Font.Color = clRed
    Font.Height = -15
    Font.Name = #23435#20307
    Font.Style = []
    ParentFont = False
  end
  object btnSave: TButton
    Left = 304
    Top = 185
    Width = 91
    Height = 29
    Anchors = [akRight, akBottom]
    Caption = #20445#23384
    Font.Charset = GB2312_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = #23435#20307
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    OnClick = btnSaveClick
  end
  object btnCancel: TButton
    Left = 120
    Top = 185
    Width = 97
    Height = 29
    Anchors = [akRight, akBottom]
    Caption = #21462#28040
    Font.Charset = GB2312_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = #23435#20307
    Font.Style = []
    ModalResult = 8
    ParentFont = False
    TabOrder = 1
  end
  object edtPModuleName: TEdit
    Left = 120
    Top = 48
    Width = 275
    Height = 23
    Font.Charset = GB2312_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = #23435#20307
    Font.Style = []
    ParentFont = False
    TabOrder = 2
  end
  object edtSModuleName: TEdit
    Left = 120
    Top = 82
    Width = 275
    Height = 23
    Font.Charset = GB2312_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = #23435#20307
    Font.Style = []
    ParentFont = False
    TabOrder = 3
  end
  object edtFormClassName: TEdit
    Left = 120
    Top = 115
    Width = 275
    Height = 23
    Font.Charset = GB2312_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = #23435#20307
    Font.Style = []
    ParentFont = False
    TabOrder = 4
  end
  object edtFormTitleName: TEdit
    Left = 120
    Top = 149
    Width = 275
    Height = 23
    Font.Charset = GB2312_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = #23435#20307
    Font.Style = []
    ParentFont = False
    TabOrder = 5
  end
  object srchbxSelectEXEFile: TSearchBox
    Left = 120
    Top = 15
    Width = 275
    Height = 23
    Font.Charset = GB2312_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = #23435#20307
    Font.Style = []
    ParentFont = False
    TabOrder = 6
    OnInvokeSearch = srchbxSelectEXEFileInvokeSearch
  end
  object dlgOpenSelectEXEFile: TOpenDialog
    Filter = 'EXE(*.EXE)|*.EXE'
    Left = 240
    Top = 8
  end
end
