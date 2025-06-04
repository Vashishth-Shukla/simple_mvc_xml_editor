object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'XML Editor'
  ClientHeight = 441
  ClientWidth = 624
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Menu = mmMenu
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object vstContent: TVirtualStringTree
    Left = 0
    Top = 0
    Width = 624
    Height = 422
    Align = alClient
    DefaultNodeHeight = 19
    Header.AutoSizeIndex = 0
    Header.Height = 15
    Header.MainColumn = -1
    TabOrder = 0
    Touch.InteractiveGestures = [igPan, igPressAndTap]
    Touch.InteractiveGestureOptions = [igoPanSingleFingerHorizontal, igoPanSingleFingerVertical, igoPanInertia, igoPanGutter, igoParentPassthrough]
    ExplicitLeft = 224
    ExplicitTop = 192
    ExplicitWidth = 200
    ExplicitHeight = 100
    Columns = <>
  end
  object sbStatus: TStatusBar
    Left = 0
    Top = 422
    Width = 624
    Height = 19
    Panels = <>
    ExplicitLeft = 320
    ExplicitTop = 232
    ExplicitWidth = 0
  end
  object ActionList: TActionList
    Top = 8
    object ActionFileSave: TAction
      Caption = 'Save'
      ShortCut = 16467
      OnExecute = ActionFileSaveExecute
    end
    object ActionFileLoad: TAction
      Caption = 'Load'
      ShortCut = 16460
      OnExecute = ActionFileLoadExecute
    end
  end
  object mmMenu: TMainMenu
    Top = 64
    object mmFile: TMenuItem
      Caption = 'File'
      object miFileNew: TMenuItem
        Caption = 'New'
      end
      object miFileOpen: TMenuItem
        Caption = 'Open...'
      end
      object miFileSave: TMenuItem
        Caption = 'Save'
      end
      object miFileSaveAs: TMenuItem
        Caption = 'Save As...'
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object miFileExit: TMenuItem
        Caption = 'Exit'
      end
    end
  end
  object popOpt: TPopupMenu
    Top = 120
    object miOptRnm: TMenuItem
      Caption = 'Rename Element'
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object miOptAdElem: TMenuItem
      Caption = 'Add Element'
      object miOptAdElmBfr: TMenuItem
        Caption = 'Add Before'
      end
      object miOptAdElmAft: TMenuItem
        Caption = 'Add After'
      end
      object miOptAdElmCld: TMenuItem
        Caption = 'Add Child'
      end
    end
    object miOptAdAttri: TMenuItem
      Caption = 'Add Attribute'
    end
    object miOptAdTxt: TMenuItem
      Caption = 'Add Text'
    end
    object miOptAdCmt: TMenuItem
      Caption = 'Add Comment'
    end
    object miOptAdCDT: TMenuItem
      Caption = 'Add CDATA'
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object miOptDlt: TMenuItem
      Caption = 'Delete'
    end
  end
end
