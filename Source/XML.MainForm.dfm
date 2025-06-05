object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'XML Editor'
  ClientHeight = 461
  ClientWidth = 624
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Menu = mmMain
  Position = poMainFormCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object vstContent: TVirtualStringTree
    Left = 0
    Top = 0
    Width = 624
    Height = 442
    Align = alClient
    DefaultNodeHeight = 19
    Header.AutoSizeIndex = 0
    Header.Height = 15
    Header.MainColumn = -1
    TabOrder = 0
    Touch.InteractiveGestures = [igPan, igPressAndTap]
    Touch.InteractiveGestureOptions = [igoPanSingleFingerHorizontal, igoPanSingleFingerVertical, igoPanInertia, igoPanGutter, igoParentPassthrough]
    Columns = <>
  end
  object sbStatus: TStatusBar
    Left = 0
    Top = 442
    Width = 624
    Height = 19
    Panels = <>
    SimplePanel = True
  end
  object popOpt: TPopupMenu
    Top = 72
    object miOptRnm: TMenuItem
      Caption = 'Rename Element'
      OnClick = miOptRnmClick
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object miOptAdElem: TMenuItem
      Caption = 'Add Element'
      object miOptAdElmBfr: TMenuItem
        Caption = 'Add Before'
        OnClick = miOptAdElmBfrClick
      end
      object miOptAdElmAft: TMenuItem
        Caption = 'Add After'
        OnClick = miOptAdElmAftClick
      end
      object miOptAdElmCld: TMenuItem
        Caption = 'Add Child'
        OnClick = miOptAdElmCldClick
      end
    end
    object miOptAdAttri: TMenuItem
      Caption = 'Add Attribute'
      OnClick = miOptAdAttriClick
    end
    object miOptAdTxt: TMenuItem
      Caption = 'Add Text'
      OnClick = miOptAdTxtClick
    end
    object miOptAdCmt: TMenuItem
      Caption = 'Add Comment'
      OnClick = miOptAdCmtClick
    end
    object miOptAdCDT: TMenuItem
      Caption = 'Add CDATA'
      OnClick = miOptAdCDTClick
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object miOptDlt: TMenuItem
      Caption = 'Delete'
      OnClick = miOptDltClick
    end
  end
  object mmMain: TMainMenu
    Top = 8
    object mmFile: TMenuItem
      Caption = 'File'
      object miFileNew: TMenuItem
        Caption = 'New'
        OnClick = miFileNewClick
      end
      object miFileOpen: TMenuItem
        Caption = 'Open...'
        OnClick = miFileOpenClick
      end
      object miFileSave: TMenuItem
        Caption = 'Save'
        OnClick = miFileSaveClick
      end
      object miFileSaveAs: TMenuItem
        Caption = 'Save As...'
        OnClick = miFileSaveAsClick
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object miFileExit: TMenuItem
        Caption = 'Exit'
        OnClick = miFileExitClick
      end
    end
  end
end
