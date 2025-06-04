unit XML.MainViewController;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  XML.MainModel,
  Winapi.msxml;

type
  ///<summary>
  /// Diese Klasse kapselt die Steuerung des XML-Datenmodells und stellt
  /// Methoden zum Einfügen, Löschen, Verwalten und Laden/Speichern von
  /// XML-Knoten bereit.
  ///</summary>
  TMainViewController = class(TObject)
  private
    FRootNode: TXmlNodeItem;
    FOnChange: TNotifyEvent;
    FOnClear: TNotifyEvent;
    procedure DoChange;
    procedure DoClear;
  public
    constructor Create;
    destructor Destroy; override;

    ///<summary>Root-Knoten der XML-Struktur.</summary>
    property RootNode: TXmlNodeItem read FRootNode;

    ///<summary>Event bei Strukturänderung.</summary>
    property OnChange: TNotifyEvent read FOnChange write FOnChange;

    ///<summary>Event beim Löschen der Struktur.</summary>
    property OnClear: TNotifyEvent read FOnClear write FOnClear;

    ///<summary>Leert die gesamte Struktur.</summary>
    procedure Clear;

    ///<summary>Benent einen beliebigen Element-/Attribut-Knoten um.</summary>
    procedure RenameNode(ANode: TXmlNodeItem; const ANewName: string);

    ///<summary>Setzt den Wert eines Text/CDATA/Comment/Attribute-Knotens.</summary>
    procedure SetNodeValue(ANode: TXmlNodeItem; const ANewValue: string);


    ///<summary>Erstellt einen Kindknoten.</summary>
    function AddChild(AParent: TXmlNodeItem; AType: TXmlNodeType;
      const AName, AValue: string): TXmlNodeItem;

    ///<summary>Fügt ein Attribut zu einem Element hinzu.</summary>
    function AddAttribute(AElement: TXmlNodeItem;
      const AName, AValue: string): TXmlNodeItem;

    ///<summary>Fügt einen neuen Knoten vor einem Referenzknoten ein.</summary>
    function InsertBefore(ARefNode: TXmlNodeItem; AType: TXmlNodeType;
      const AName, AValue: string): TXmlNodeItem;

    ///<summary>Fügt einen neuen Knoten nach einem Referenzknoten ein.</summary>
    function InsertAfter(ARefNode: TXmlNodeItem; AType: TXmlNodeType;
      const AName, AValue: string): TXmlNodeItem;

    ///<summary>Entfernt einen bestimmten Knoten.</summary>
    procedure DeleteNode(ANode: TXmlNodeItem);

    ///<summary>Lädt eine XML-Datei und erstellt die Struktur.</summary>
    procedure LoadFromXml(const AFilename: string);

    ///<summary>Speichert die Struktur in eine XML-Datei.</summary>
    procedure SaveToXml(const AFilename: string);
  end;

implementation

//------------------------------------------------------------------------------
constructor TMainViewController.Create;
begin
  inherited;
  FRootNode := TXmlNodeItem.Create(ntElement);
  FRootNode.Name := 'root';
end;

//------------------------------------------------------------------------------
destructor TMainViewController.Destroy;
begin
  FreeAndNil(FRootNode);
  inherited;
end;

//------------------------------------------------------------------------------
procedure TMainViewController.DoChange;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

//------------------------------------------------------------------------------
procedure TMainViewController.DoClear;
begin
  if Assigned(FOnClear) then
    FOnClear(Self);
end;

//------------------------------------------------------------------------------
procedure TMainViewController.Clear;
begin
  DoClear;
  FRootNode.Children.Clear;
  FRootNode.Attributes.Clear;
  DoChange;
end;

//------------------------------------------------------------------------------
procedure TMainViewController.RenameNode(ANode: TXmlNodeItem; const ANewName: string);
begin
  if not Assigned(ANode) then
    Exit;

  if ANode.NodeType in [ntElement, ntAttribute] then
  begin
    ANode.Name := ANewName;
    DoChange;
  end;
end;

//------------------------------------------------------------------------------
procedure TMainViewController.SetNodeValue(ANode: TXmlNodeItem; const ANewValue: string);
begin
  if not Assigned(ANode) then
    Exit;

  if ANode.NodeType <> ntElement then
  begin
    ANode.Value := ANewValue;
    DoChange;
  end;
end;

//------------------------------------------------------------------------------
function TMainViewController.AddChild(AParent: TXmlNodeItem;
  AType: TXmlNodeType; const AName, AValue: string): TXmlNodeItem;
begin
  Result := TXmlNodeItem.Create(AType);
  Result.Parent := AParent;
  if AType in [ntElement, ntAttribute] then
    Result.Name := AName;
  if AType <> ntElement then
    Result.Value := AValue;

  if AParent.NodeType = ntElement then
    AParent.Children.Add(Result);

  DoChange;
end;

//------------------------------------------------------------------------------
function TMainViewController.AddAttribute(AElement: TXmlNodeItem;
  const AName, AValue: string): TXmlNodeItem;
begin
  Result := TXmlNodeItem.Create(ntAttribute);
  Result.Name := AName;
  Result.Value := AValue;
  Result.Parent := AElement;
  AElement.Attributes.Add(Result);
  DoChange;
end;

//------------------------------------------------------------------------------
function TMainViewController.InsertBefore(ARefNode: TXmlNodeItem;
  AType: TXmlNodeType; const AName, AValue: string): TXmlNodeItem;
var
  ParentList: TObjectList<TXmlNodeItem>;
  Index: Integer;
begin
  Result := TXmlNodeItem.Create(AType);
  Result.Parent := ARefNode.Parent;
  if AType in [ntElement, ntAttribute] then
    Result.Name := AName;
  if AType <> ntElement then
    Result.Value := AValue;

  if Assigned(Result.Parent) then
  begin
    ParentList := Result.Parent.Children;
    Index := ParentList.IndexOf(ARefNode);
    if Index >= 0 then
      ParentList.Insert(Index, Result);
  end;

  DoChange;
end;

//------------------------------------------------------------------------------
function TMainViewController.InsertAfter(ARefNode: TXmlNodeItem;
  AType: TXmlNodeType; const AName, AValue: string): TXmlNodeItem;
var
  ParentList: TObjectList<TXmlNodeItem>;
  Index: Integer;
begin
  Result := TXmlNodeItem.Create(AType);
  Result.Parent := ARefNode.Parent;
  if AType in [ntElement, ntAttribute] then
    Result.Name := AName;
  if AType <> ntElement then
    Result.Value := AValue;

  if Assigned(Result.Parent) then
  begin
    ParentList := Result.Parent.Children;
    Index := ParentList.IndexOf(ARefNode);
    if Index >= 0 then
      ParentList.Insert(Index + 1, Result);
  end;

  DoChange;
end;

//------------------------------------------------------------------------------
procedure TMainViewController.DeleteNode(ANode: TXmlNodeItem);
begin
  if not Assigned(ANode) or not ANode.HasParent then
    Exit;

  if ANode.NodeType = ntAttribute then
    ANode.Parent.Attributes.Remove(ANode)
  else
    ANode.Parent.Children.Remove(ANode);

  DoChange;
end;

//------------------------------------------------------------------------------
procedure TMainViewController.LoadFromXml(const AFilename: string);
var
  Doc: IXMLDOMDocument;

  function CreateNode(XMLNode: IXMLDOMNode): TXmlNodeItem;
  var
    Attr: TXmlNodeItem;
    SubNode: IXMLDOMNode;
  begin
    Result := TXmlNodeItem.Create(ntElement);
    Result.Name := XMLNode.nodeName;

    for var i := 0 to XMLNode.attributes.length - 1 do
    begin
      Attr := TXmlNodeItem.Create(ntAttribute);
      Attr.Name := XMLNode.attributes.item[i].nodeName;
      Attr.Value := XMLNode.attributes.item[i].text;
      Attr.Parent := Result;
      Result.Attributes.Add(Attr);
    end;

    for var i := 0 to XMLNode.childNodes.length - 1 do
    begin
      SubNode := XMLNode.childNodes.item[i];

      case SubNode.nodeType of
        NODE_ELEMENT:
          Result.Children.Add(CreateNode(SubNode));
        NODE_TEXT:
          Result.Children.Add(AddChild(Result, ntText, '', SubNode.text));
        NODE_CDATA_SECTION:
          Result.Children.Add(AddChild(Result, ntCData, '', SubNode.text));
        NODE_COMMENT:
          Result.Children.Add(AddChild(Result, ntComment, '', SubNode.text));
      end;
    end;
  end;

begin
  Doc := CoFreeThreadedDOMDocument40.Create;
  if Doc.load(AFilename) then
  begin
    Clear;
    FRootNode.Name := Doc.documentElement.nodeName;
    for var i := 0 to Doc.documentElement.childNodes.length - 1 do
    begin
      if Doc.documentElement.childNodes.item[i].nodeType = NODE_ELEMENT then
        FRootNode.Children.Add(CreateNode(Doc.documentElement.childNodes.item[i]));
    end;
    DoChange;
  end;
end;

//------------------------------------------------------------------------------
procedure TMainViewController.SaveToXml(const AFilename: string);
var
  Doc: IXMLDOMDocument;

  procedure SaveNode(ANode: TXmlNodeItem; AParent: IXMLDOMElement);
  var
    Node: IXMLDOMElement;
  begin
    for var Attr in ANode.Attributes do
      AParent.setAttribute(Attr.Name, Attr.Value);

    for var Child in ANode.Children do
    begin
      case Child.NodeType of
        ntElement:
        begin
          Node := Doc.createElement(Child.Name);
          AParent.appendChild(Node);
          SaveNode(Child, Node);
        end;
        ntText:
          AParent.appendChild(Doc.createTextNode(Child.Value));
        ntCData:
          AParent.appendChild(Doc.createCDATASection(Child.Value));
        ntComment:
          AParent.appendChild(Doc.createComment(Child.Value));
      end;
    end;
  end;

begin
  Doc := CoFreeThreadedDOMDocument40.Create;
  Doc.loadXML(Format('<?xml version="1.0" encoding="UTF-8"?><%s/>', [FRootNode.Name]));
  SaveNode(FRootNode, Doc.documentElement);
  Doc.save(AFilename);
end;

end.

