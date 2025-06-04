unit XML.MainForm;

interface

uses
  System.SysUtils, System.Variants, System.Classes, System.Actions,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ActnList,
  Vcl.Menus, Vcl.ComCtrls, Vcl.ExtDlgs,
  XML.MainViewController,
  XML.MainModel,
  VirtualTrees, VirtualTrees.BaseAncestorVCL,
  VirtualTrees.BaseTree, VirtualTrees.AncestorVCL;

type
  TMainForm = class(TForm)
    ActionList: TActionList;
    ActionFileSave: TAction;
    ActionFileLoad: TAction;

    vstContent: TVirtualStringTree;
    mmMenu: TMainMenu;
    mmFile: TMenuItem;
    miFileNew: TMenuItem;
    miFileOpen: TMenuItem;
    miFileSave: TMenuItem;
    miFileSaveAs: TMenuItem;
    N1: TMenuItem;
    miFileExit: TMenuItem;

    popOpt: TPopupMenu;
    miOptRnm: TMenuItem;
    N3: TMenuItem;
    miOptAdElem: TMenuItem;
    miOptAdElmBfr: TMenuItem;
    miOptAdElmAft: TMenuItem;
    miOptAdElmCld: TMenuItem;
    miOptAdAttri: TMenuItem;
    miOptAdTxt: TMenuItem;
    miOptAdCmt: TMenuItem;
    miOptAdCDT: TMenuItem;
    N2: TMenuItem;
    miOptDlt: TMenuItem;

    sbStatus: TStatusBar;

    FileOpenDialog: TFileOpenDialog;
    FileSaveDialog: TFileSaveDialog;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ActionFileSaveExecute(Sender: TObject);
    procedure ActionFileLoadExecute(Sender: TObject);
    procedure vstContentGetText(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex;
      TextType: TVSTTextType; var CellText: string);
    procedure vstContentGetNodeDataSize(Sender: TBaseVirtualTree;
      var NodeDataSize: Integer);
    procedure vstContentPopup(Sender: TObject);
    procedure miOptRnmClick(Sender: TObject);
    procedure miFileOpenClick(Sender: TObject);
    procedure miFileSaveClick(Sender: TObject);
  private
    FViewController: TMainViewController;
    FLoadedFileName: string;

    procedure ShowStatus(const Msg: string; AColor: TColor);
    procedure UpdateVirtualTree;
    procedure PopulateNode(ParentNode: PVirtualNode; XmlNode: TXmlNodeItem);
    function GetSelectedXmlNode: TXmlNodeItem;

    procedure ViewControllerOnChange(Sender: TObject);
    procedure ViewControllerOnClear(Sender: TObject);
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

const
  COLOR_SUCCESS = clGreen;
  COLOR_ERROR   = clRed;
  COLOR_INFO    = clGray;

//------------------------------------------------------------------------------
// Form lifecycle
//------------------------------------------------------------------------------
procedure TMainForm.FormCreate(Sender: TObject);
begin
  FViewController := TMainViewController.Create;
  FViewController.OnChange := ViewControllerOnChange;
  FViewController.OnClear := ViewControllerOnClear;

  vstContent.NodeDataSize := SizeOf(Pointer);
  vstContent.PopupMenu := popOpt;

  vstContent.Header.Columns.Clear;
  with vstContent.Header.Columns.Add do Text := 'Name';
  with vstContent.Header.Columns.Add do Text := 'Value';

  if sbStatus.Panels.Count = 0 then
    sbStatus.Panels.Add;

  ShowStatus('Ready.', COLOR_INFO);
end;

//------------------------------------------------------------------------------
procedure TMainForm.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FViewController);
end;

//------------------------------------------------------------------------------
// File actions
//------------------------------------------------------------------------------
procedure TMainForm.miFileOpenClick(Sender: TObject);
begin
  if FileOpenDialog.Execute then
  begin
    try
      FLoadedFileName := FileOpenDialog.FileName;
      FViewController.LoadFromXml(FLoadedFileName);
      ShowStatus('File loaded: ' + ExtractFileName(FLoadedFileName), COLOR_SUCCESS);
    except
      on E: Exception do
        ShowStatus('Load failed: ' + E.Message, COLOR_ERROR);
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TMainForm.miFileSaveClick(Sender: TObject);
begin
  if (FLoadedFileName = '') or not FileExists(FLoadedFileName) then
  begin
    if not FileSaveDialog.Execute then Exit;
    FLoadedFileName := FileSaveDialog.FileName;
  end;

  try
    FViewController.SaveToXml(FLoadedFileName);
    ShowStatus('Saved: ' + ExtractFileName(FLoadedFileName), COLOR_SUCCESS);
  except
    on E: Exception do
      ShowStatus('Save failed: ' + E.Message, COLOR_ERROR);
  end;
end;

//------------------------------------------------------------------------------
// Action handlers for testing (optional)
procedure TMainForm.ActionFileLoadExecute(Sender: TObject);
begin
  miFileOpenClick(Sender);
end;

//------------------------------------------------------------------------------
procedure TMainForm.ActionFileSaveExecute(Sender: TObject);
begin
  miFileSaveClick(Sender);
end;

//------------------------------------------------------------------------------
// Status bar helper
//------------------------------------------------------------------------------
procedure TMainForm.ShowStatus(const Msg: string; AColor: TColor);
begin
  sbStatus.Color := AColor;
  sbStatus.Panels[0].Text := Msg;
end;

//------------------------------------------------------------------------------
// Tree rendering
//------------------------------------------------------------------------------
procedure TMainForm.UpdateVirtualTree;
begin
  vstContent.BeginUpdate;
  try
    vstContent.Clear;
    PopulateNode(nil, FViewController.RootNode);
    vstContent.FullExpand;
  finally
    vstContent.EndUpdate;
  end;
end;

//------------------------------------------------------------------------------
procedure TMainForm.PopulateNode(ParentNode: PVirtualNode;
  XmlNode: TXmlNodeItem);
var
  Node: PVirtualNode;
  Child: TXmlNodeItem;
begin
  Node := vstContent.AddChild(ParentNode);
  PPointer(vstContent.GetNodeData(Node))^ := XmlNode;

  if XmlNode.NodeType = ntElement then
  begin
    for Child in XmlNode.Attributes do
      PopulateNode(Node, Child);
    for Child in XmlNode.Children do
      PopulateNode(Node, Child);
  end;
end;

//------------------------------------------------------------------------------
// Tree node access
//------------------------------------------------------------------------------
function TMainForm.GetSelectedXmlNode: TXmlNodeItem;
begin
  if Assigned(vstContent.FocusedNode) then
    Result := TXmlNodeItem(PPointer(vstContent.GetNodeData(vstContent.FocusedNode))^)
  else
    Result := nil;
end;

//------------------------------------------------------------------------------
// VirtualTree handlers
//------------------------------------------------------------------------------
procedure TMainForm.vstContentGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: string);
var
  Xml: TXmlNodeItem;
begin
  Xml := TXmlNodeItem(PPointer(Sender.GetNodeData(Node))^);
  if not Assigned(Xml) then Exit;

  case Column of
    0:
      case Xml.NodeType of
        ntElement: CellText := Xml.Name;
        ntAttribute: CellText := '@' + Xml.Name;
        ntComment: CellText := '#comment';
        ntText: CellText := '#text';
        ntCData: CellText := '#cdata';
      else
        CellText := Xml.Name;
      end;
    1: CellText := Xml.Value;
  end;
end;

//------------------------------------------------------------------------------
procedure TMainForm.vstContentGetNodeDataSize(Sender: TBaseVirtualTree;
  var NodeDataSize: Integer);
begin
  NodeDataSize := SizeOf(Pointer);
end;

//------------------------------------------------------------------------------
// Events from controller
//------------------------------------------------------------------------------
procedure TMainForm.ViewControllerOnChange(Sender: TObject);
begin
  UpdateVirtualTree;
  ShowStatus('Tree updated.', COLOR_SUCCESS);
end;

//------------------------------------------------------------------------------
procedure TMainForm.ViewControllerOnClear(Sender: TObject);
begin
  vstContent.Clear;
  ShowStatus('Cleared.', COLOR_SUCCESS);
end;

//------------------------------------------------------------------------------
// Rename logic
//------------------------------------------------------------------------------
procedure TMainForm.miOptRnmClick(Sender: TObject);
var
  Node: TXmlNodeItem;
  NewName: string;
begin
  Node := GetSelectedXmlNode;
  if not Assigned(Node) then Exit;

  NewName := InputBox('Rename Node', 'Enter new name:', Node.Name);
  if NewName <> '' then
  begin
    FViewController.RenameNode(Node, NewName);
    ShowStatus('Node renamed.', COLOR_SUCCESS);
  end;
end;

//------------------------------------------------------------------------------
// Context menu filter
//------------------------------------------------------------------------------
procedure TMainForm.vstContentPopup(Sender: TObject);
var
  Node: TXmlNodeItem;
begin
  Node := GetSelectedXmlNode;
  if not Assigned(Node) or (Node.NodeType <> ntElement) then
    Abort; // Block popup for non-element nodes
end;

end.
