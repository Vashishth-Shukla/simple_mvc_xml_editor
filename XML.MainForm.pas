unit XML.MainForm;

interface

uses
  System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Vcl.Menus, Vcl.ComCtrls, VirtualTrees, VirtualTrees.Types,
  XML.MainViewController, XML.MainModel, VirtualTrees.BaseAncestorVCL,
  VirtualTrees.BaseTree, VirtualTrees.AncestorVCL;

type
  TNodeData = record
    Xml: TXmlNodeItem;
  end;

  PNodeData = ^TNodeData;

  TMainForm = class(TForm)
    vstContent: TVirtualStringTree;
    sbStatus: TStatusBar;
    popOpt: TPopupMenu;
    miOptRnm: TMenuItem;
    miOptDlt: TMenuItem;
    N2: TMenuItem;
    miOptAdAttri: TMenuItem;
    miOptAdElem: TMenuItem;
    miOptAdElmBfr: TMenuItem;
    miOptAdElmAft: TMenuItem;
    miOptAdElmCld: TMenuItem;
    miOptAdTxt: TMenuItem;
    miOptAdCmt: TMenuItem;
    miOptAdCDT: TMenuItem;
    mmMain: TMainMenu;
    mmFile: TMenuItem;
    miFileNew: TMenuItem;
    miFileOpen: TMenuItem;
    miFileSave: TMenuItem;
    miFileSaveAs: TMenuItem;
    N1: TMenuItem;
    miFileExit: TMenuItem;

    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormDestroy(Sender: TObject);
    procedure vstContentGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure vstContentGetNodeDataSize(Sender: TBaseVirtualTree;
      var NodeDataSize: Integer);
    procedure vstContentEditing(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; var Allowed: Boolean);
    procedure vstContentNewText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; NewText: string);
    procedure vstContentDblClick(Sender: TObject);
    procedure popOptPopup(Sender: TObject);
    procedure miOptRnmClick(Sender: TObject);
    procedure miOptAdElmBfrClick(Sender: TObject);
    procedure miOptAdElmAftClick(Sender: TObject);
    procedure miOptAdElmCldClick(Sender: TObject);
    procedure miOptAdAttriClick(Sender: TObject);
    procedure miOptAdTxtClick(Sender: TObject);
    procedure miOptAdCmtClick(Sender: TObject);
    procedure miOptAdCDTClick(Sender: TObject);
    procedure miOptDltClick(Sender: TObject);
    procedure miFileNewClick(Sender: TObject);
    procedure miFileOpenClick(Sender: TObject);
    procedure miFileSaveClick(Sender: TObject);
    procedure miFileSaveAsClick(Sender: TObject);
    procedure miFileExitClick(Sender: TObject);
  private
    FController: TMainViewController;
    FCurrentFileName: string;
    FIsModified: Boolean;
    procedure InitializeTree;
    procedure UpdateTree;
    procedure PopulateNode(Parent: PVirtualNode; ModelNode: TXmlNodeItem);
    function GetSelectedNode: TXmlNodeItem;
    function ConfirmDiscardChanges: Boolean;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}


procedure TMainForm.FormCreate(Sender: TObject);
begin
  sbStatus.SimplePanel := True;
  FController := TMainViewController.Create;
  InitializeTree;
  vstContent.PopupMenu := popOpt;
  popOpt.OnPopup := popOptPopup;
  vstContent.OnEditing := vstContentEditing;
  vstContent.OnNewText := vstContentNewText;
  vstContent.OnDblClick := vstContentDblClick;
  miFileNewClick(nil);
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := ConfirmDiscardChanges;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FController);
end;

// add further logic ... yes no what ... possibly distroy the nodes here once chosen ... more logic
function TMainForm.ConfirmDiscardChanges: Boolean;
begin
  Result := True;
  if FIsModified then
    Result := MessageDlg('You have unsaved changes. Do you want to discard them?', mtConfirmation, [mbYes, mbNo], 0) = mrYes;
end;

procedure TMainForm.InitializeTree;
begin
  vstContent.NodeDataSize := SizeOf(TNodeData);
  vstContent.Header.Options := [hoVisible, hoColumnResize];
  vstContent.TreeOptions.PaintOptions := [toShowHorzGridLines, toShowVertGridLines, toShowTreeLines, toShowButtons];
  vstContent.TreeOptions.MiscOptions := [toEditable, toToggleOnDblClick, toFullRepaintOnResize, toGridExtensions];
  vstContent.Header.Columns.Clear;
  with vstContent.Header.Columns.Add do begin Text := 'Name'; Width := 200; end;
  with vstContent.Header.Columns.Add do begin Text := 'Value'; Width := 400; end;
  vstContent.OnGetText := vstContentGetText;
  vstContent.OnGetNodeDataSize := vstContentGetNodeDataSize;
end;

procedure TMainForm.UpdateTree;
begin
  vstContent.BeginUpdate;
  try
    vstContent.Clear;
    if Assigned(FController.RootNode) then
      PopulateNode(nil, FController.RootNode);
    vstContent.FullExpand;
  finally
    vstContent.EndUpdate;
  end;
end;

procedure TMainForm.PopulateNode(Parent: PVirtualNode; ModelNode: TXmlNodeItem);
var
  Node: PVirtualNode;
  Data: PNodeData;
  Child: TXmlNodeItem;
begin
  Node := vstContent.AddChild(Parent);
  Data := vstContent.GetNodeData(Node);
  if Assigned(Data) then
    Data^.Xml := ModelNode;
  if ModelNode.NodeType = ntElement then
  begin
    for Child in ModelNode.Attributes do
      PopulateNode(Node, Child);
    for Child in ModelNode.Children do
      if Child.NodeType in [ntElement,  ntText, ntCData, ntComment] then
        PopulateNode(Node, Child);
  end;
end;

function TMainForm.GetSelectedNode: TXmlNodeItem;
var
  Data: PNodeData;
begin
  if Assigned(vstContent.FocusedNode) then
  begin
    Data := vstContent.GetNodeData(vstContent.FocusedNode);
    if Assigned(Data) then
      Result := Data^.Xml
    else
      Result := nil;
  end
  else
    Result := nil;
end;

procedure TMainForm.vstContentGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
  Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
var
  Data: PNodeData;
  Xml: TXmlNodeItem;
begin
  Data := Sender.GetNodeData(Node);
  if not Assigned(Data) then Exit;
  Xml := Data^.Xml;
  case Column of
    0:
      case Xml.NodeType of
        ntElement:   CellText := Xml.Name;
        ntAttribute: CellText := '@' + Xml.Name;
        ntComment:   CellText := '#comment';
        ntText:      CellText := '#text';
        ntCData:     CellText := '#cdata';
      else
        CellText := Xml.Name;
      end;
    1: CellText := Xml.Value;
  end;
end;

procedure TMainForm.vstContentGetNodeDataSize(Sender: TBaseVirtualTree;
  var NodeDataSize: Integer);
begin
  NodeDataSize := SizeOf(TNodeData);
end;

procedure TMainForm.vstContentEditing(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; var Allowed: Boolean);
begin
  Allowed := Column = 1;
end;

procedure TMainForm.vstContentNewText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; NewText: string);
var
  Data: PNodeData;
begin
  if Column <> 1 then Exit;
  Data := Sender.GetNodeData(Node);
  if Assigned(Data) and Assigned(Data.Xml) then
  begin
    if Data.Xml.NodeType = ntElement then
    begin
      sbStatus.SimpleText := 'Cannot assign value directly to element node.';
      Exit;
    end;
    Data.Xml.Value := NewText;
    FIsModified := True;
    sbStatus.SimpleText := 'Node value updated.';
  end;
end;


procedure TMainForm.vstContentDblClick(Sender: TObject);
var
  Node: TXmlNodeItem;
begin
  Node := GetSelectedNode;

  if Assigned(vstContent.FocusedNode) and (Node.NodeType <> ntElement) then
    vstContent.EditNode(vstContent.FocusedNode, 1);

end;

procedure TMainForm.popOptPopup(Sender: TObject);
var
  Node: TXmlNodeItem;
begin
  Node := GetSelectedNode;
  miOptRnm.Enabled      := Assigned(Node) and (Node.NodeType in [ntElement, ntAttribute]);

  miOptAdElem.Enabled   := Assigned(Node) and (Node.NodeType = ntElement);
  miOptAdElmBfr.Enabled := Assigned(Node) and Node.HasParent;
  miOptAdElmAft.Enabled := Assigned(Node) and Node.HasParent;
  miOptAdElmCld.Enabled := Assigned(Node) and (Node.NodeType = ntElement);

  miOptAdAttri.Enabled  := Assigned(Node) and (Node.NodeType = ntElement);

  miOptAdTxt.Enabled    := Assigned(Node) and (Node.NodeType = ntElement);
  miOptAdCmt.Enabled    := Assigned(Node) and (Node.NodeType = ntElement);
  miOptAdCDT.Enabled    := Assigned(Node) and (Node.NodeType = ntElement);
  miOptDlt.Enabled     := Assigned(Node) and Node.HasParent;
end;

procedure TMainForm.miOptRnmClick(Sender: TObject);
var
  Node: TXmlNodeItem;
  NewName: string;
begin
  Node := GetSelectedNode;
  if not Assigned(Node) then Exit;
  NewName := InputBox('Rename', 'New name:', Node.Name);
  if NewName <> '' then
    FController.RenameNode(Node, NewName);
  UpdateTree;
  sbStatus.SimpleText := 'Node renamed.';
end;


procedure TMainForm.miOptAdElmBfrClick(Sender: TObject);
var
  NodeName : string;
begin
  NodeName := InputBox('Enter Node Name', 'Name:', '');
  if NodeName = '' then Exit;
  FController.InsertBefore(GetSelectedNode, ntElement, NodeName, '');
  UpdateTree;
  sbStatus.SimpleText := 'Element inserted before.';
end;

procedure TMainForm.miOptAdElmAftClick(Sender: TObject);
var
  NodeName : string;
begin
  NodeName := InputBox('Enter Node Name', 'Name:', '');
  if NodeName = '' then Exit;
  FController.InsertAfter(GetSelectedNode, ntElement, NodeName, '');
  UpdateTree;
  sbStatus.SimpleText := 'Element inserted after.';
end;


procedure TMainForm.miOptAdElmCldClick(Sender: TObject);
var
  NodeName : string;
begin
  NodeName := InputBox('Enter Node Name', 'Name:', '');
  if NodeName = '' then Exit;
  FController.AddChild(GetSelectedNode, ntElement, NodeName, '');
  UpdateTree;
  sbStatus.SimpleText := 'Child element added.';
end;


procedure TMainForm.miOptAdAttriClick(Sender: TObject);
var
  AttriName : string;
  AttriVal  : string;
begin
  AttriName := InputBox('Enter Attribute Name', 'Attribute Name:', '');
  if AttriName = '' then Exit;
  AttriVal := InputBox('Enter Value', 'Attribure Value:', '');
  FController.AddAttribute(GetSelectedNode, AttriName, AttriVal);
  UpdateTree;
  sbStatus.SimpleText := 'Attribute added.';
end;

procedure TMainForm.miOptAdTxtClick(Sender: TObject);
var
  NodeValue : string;
begin
  NodeValue := InputBox('Enter Text', 'Text:', '');
  if NodeValue = '' then Exit;
  FController.AddChild(GetSelectedNode, ntText, '', NodeValue);
  UpdateTree;
  sbStatus.SimpleText := 'Text node added.';
end;

procedure TMainForm.miOptAdCmtClick(Sender: TObject);
var
  NodeValue : string;
begin
  NodeValue := InputBox('Enter Comment', 'Comment:', '');
  if NodeValue = '' then Exit;
  FController.AddChild(GetSelectedNode, ntComment, '', NodeValue);
  UpdateTree;
  sbStatus.SimpleText := 'Comment node added.';
end;

procedure TMainForm.miOptAdCDTClick(Sender: TObject);
var
  NodeValue : string;
begin
  NodeValue := InputBox('Enter CDATA', 'CDATA:', '');
  if NodeValue = '' then Exit;
  FController.AddChild(GetSelectedNode, ntCData, '', NodeValue);
  UpdateTree;
  sbStatus.SimpleText := 'CDATA node added.';
end;

procedure TMainForm.miOptDltClick(Sender: TObject);
begin
  FController.DeleteNode(GetSelectedNode);
  UpdateTree;
  sbStatus.SimpleText := 'Node deleted.';
end;

// check if old is gone ... and new is created
procedure TMainForm.miFileNewClick(Sender: TObject);
begin
  if not ConfirmDiscardChanges then Exit;
  FController.Clear;
  FCurrentFileName := '';
  FIsModified := True;
  UpdateTree;
  sbStatus.SimpleText := 'New XML created.';
end;

procedure TMainForm.miFileOpenClick(Sender: TObject);
var
  Dlg: TOpenDialog;
begin
  if not ConfirmDiscardChanges then Exit;
  Dlg := TOpenDialog.Create(nil);
  try
    Dlg.Filter := 'XML files (*.xml)|*.xml|All files (*.*)|*.*';
    if Dlg.Execute then
    begin
      try
        FController.LoadFromXml(Dlg.FileName);
        FCurrentFileName := Dlg.FileName;
        FIsModified := False;
        UpdateTree;
        sbStatus.SimpleText := 'File loaded.';
      except
        on E: Exception do
          ShowMessage('Error loading: ' + E.Message);
      end;
    end;
  finally
    Dlg.Free;
  end;
end;

procedure TMainForm.miFileSaveClick(Sender: TObject);
begin
  if FCurrentFileName = '' then
    miFileSaveAsClick(Sender)
  else
  begin
    try
      FController.SaveToXml(FCurrentFileName);
      FIsModified := False;
      sbStatus.SimpleText := 'File saved.';
    except
      on E: Exception do
        ShowMessage('Error saving: ' + E.Message);
    end;
  end;
end;

procedure TMainForm.miFileSaveAsClick(Sender: TObject);
var
  Dlg: TSaveDialog;
begin
  Dlg := TSaveDialog.Create(Self);
  try
    Dlg.Filter := 'XML files (*.xml)|*.xml|All files (*.*)|*.*';
    Dlg.DefaultExt := '.xml';
    Dlg.Title := 'Save XML File As';
    Dlg.Options := Dlg.Options + [ofOverwritePrompt];

    if Dlg.Execute then
    begin
      FController.SaveToXml(Dlg.FileName);
      FCurrentFileName := Dlg.FileName;
      FIsModified := False;
      sbStatus.SimpleText := 'File saved.';
    end;
  finally
    Dlg.Free;
  end;
end;

procedure TMainForm.miFileExitClick(Sender: TObject);
begin
  Close;
end;

end.

