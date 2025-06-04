unit XML.MainForm;

interface

uses
  System.SysUtils,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.Menus,
  Vcl.ComCtrls,
  VirtualTrees,
  VirtualTrees.Types,
  XML.MainViewController,
  XML.MainModel,
  VirtualTrees.BaseAncestorVCL,
  VirtualTrees.BaseTree,
  VirtualTrees.AncestorVCL;

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
    procedure FormDestroy(Sender: TObject);
    procedure vstContentGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure vstContentGetNodeDataSize(Sender: TBaseVirtualTree;
      var NodeDataSize: Integer);
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
    procedure ShowStatus(const Msg: string; AColor: TColor);
    procedure InitializeTree;
    procedure UpdateTree;
    procedure PopulateNode(Parent: PVirtualNode; ModelNode: TXmlNodeItem);
    function GetSelectedNode: TXmlNodeItem;
    procedure OnChange(Sender: TObject);
    procedure OnClear(Sender: TObject);
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

const
  COLOR_OK = clGreen;
  COLOR_ERR = clRed;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  FController := TMainViewController.Create;
  FController.OnChange := OnChange;
  FController.OnClear := OnClear;
  InitializeTree;
  vstContent.PopupMenu := popOpt;
  popOpt.OnPopup := popOptPopup;
  sbStatus.Panels.Add;
  ShowStatus('Ready.', clGray);
  miFileNewClick(nil);
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FController);
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

procedure TMainForm.ShowStatus(const Msg: string; AColor: TColor);
begin
   // sbStatus.Color := AColor;
  sbStatus.SimpleText := Msg;
end;

procedure TMainForm.OnChange(Sender: TObject);
begin
  UpdateTree;
  FIsModified := True;
end;

procedure TMainForm.OnClear(Sender: TObject);
begin
  vstContent.Clear;
end;

procedure TMainForm.UpdateTree;
begin
  vstContent.BeginUpdate;
  try
    vstContent.Clear;
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

procedure TMainForm.popOptPopup(Sender: TObject);
var
  Node: TXmlNodeItem;
begin
  Node := GetSelectedNode;
  miOptAdAttri.Enabled := Assigned(Node) and (Node.NodeType = ntElement);
  miOptAdElmBfr.Enabled := Assigned(Node) and Node.HasParent;
  miOptAdElmAft.Enabled := Assigned(Node) and Node.HasParent;
  miOptAdElmCld.Enabled := Assigned(Node) and (Node.NodeType = ntElement);
  miOptDlt.Enabled := Assigned(Node) and Node.HasParent;
  miOptRnm.Enabled := Assigned(Node) and (Node.NodeType in [ntElement, ntAttribute]);
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
end;

procedure TMainForm.miOptAdElmBfrClick(Sender: TObject);
begin
  FController.InsertBefore(GetSelectedNode, ntElement, 'element', '');
end;

procedure TMainForm.miOptAdElmAftClick(Sender: TObject);
begin
  FController.InsertAfter(GetSelectedNode, ntElement, 'element', '');
end;

procedure TMainForm.miOptAdElmCldClick(Sender: TObject);
begin
  FController.AddChild(GetSelectedNode, ntElement, 'element', '');
end;

procedure TMainForm.miOptAdAttriClick(Sender: TObject);
begin
  FController.AddAttribute(GetSelectedNode, 'attribute', 'value');
end;

procedure TMainForm.miOptAdTxtClick(Sender: TObject);
begin
  FController.AddChild(GetSelectedNode, ntText, '', 'text value');
end;

procedure TMainForm.miOptAdCmtClick(Sender: TObject);
begin
  FController.AddChild(GetSelectedNode, ntComment, '', 'comment here');
end;

procedure TMainForm.miOptAdCDTClick(Sender: TObject);
begin
  FController.AddChild(GetSelectedNode, ntCData, '', 'cdata content');
end;

procedure TMainForm.miOptDltClick(Sender: TObject);
begin
  FController.DeleteNode(GetSelectedNode);
end;

procedure TMainForm.miFileNewClick(Sender: TObject);
begin
  FController.Clear;
  FCurrentFileName := '';
  FIsModified := True;
  UpdateTree;
  ShowStatus('New XML created.', COLOR_OK);
end;

procedure TMainForm.miFileOpenClick(Sender: TObject);
var
  Dlg: TOpenDialog;
begin
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
        ShowStatus('File loaded.', COLOR_OK);
      except
        on E: Exception do
          ShowStatus('Error loading: ' + E.Message, COLOR_ERR);
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
      // ShowStatus('File saved.', COLOR_OK);
    except
      on E: Exception do
        // ShowStatus('Error saving: ' + E.Message, COLOR_ERR);
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

    if Dlg.Execute then
    begin
      FController.SaveToXml(Dlg.FileName);
      FCurrentFileName := Dlg.FileName;
      FIsModified := False;
      ShowStatus('File saved.', COLOR_OK);
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

