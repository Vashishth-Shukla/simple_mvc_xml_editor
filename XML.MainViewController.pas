unit XML.MainViewController;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  XML.MainModel;

type
  TMainViewController = class
  private
    FRootNode: TXmlNodeItem;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Clear;
    function AddChild(AParent: TXmlNodeItem; AType: TXmlNodeType; const AName, AValue: string): TXmlNodeItem;
    function AddAttribute(AParent: TXmlNodeItem; const AName, AValue: string): TXmlNodeItem;
    procedure DeleteNode(ANode: TXmlNodeItem);
    procedure RenameNode(ANode: TXmlNodeItem; const ANewName: string);
    procedure SetNodeValue(ANode: TXmlNodeItem; const ANewValue: string);
    procedure InsertBefore(ANode: TXmlNodeItem; AType: TXmlNodeType; const AName, AValue: string);
    procedure InsertAfter(ANode: TXmlNodeItem; AType: TXmlNodeType; const AName, AValue: string);
    procedure LoadFromXml(const Filename: string);
    procedure SaveToXml(const Filename: string);
    property RootNode: TXmlNodeItem read FRootNode;
  end;

implementation

uses
  Winapi.msxml;

constructor TMainViewController.Create;
begin
  inherited;
  Clear;
end;

destructor TMainViewController.Destroy;
begin
  FRootNode.Free;
  inherited;
end;

procedure TMainViewController.Clear;
begin
  FRootNode.Free;
  FRootNode := TXmlNodeItem.Create(ntElement);
  FRootNode.Name := 'root';
end;

function TMainViewController.AddChild(AParent: TXmlNodeItem; AType: TXmlNodeType; const AName, AValue: string): TXmlNodeItem;
begin
  Result := TXmlNodeItem.Create(AType);
  Result.Parent := AParent;
  Result.Name := AName;
  Result.Value := AValue;

  if Result.NodeType = ntAttribute then
    AParent.Attributes.Add(Result)
  else
    AParent.Children.Add(Result);
end;

function TMainViewController.AddAttribute(AParent: TXmlNodeItem; const AName, AValue: string): TXmlNodeItem;
begin
  Result := AddChild(AParent, ntAttribute, AName, AValue);
end;

// you cannot delete the root but rename it
procedure TMainViewController.DeleteNode(ANode: TXmlNodeItem);
begin
  if Assigned(ANode) and Assigned(ANode.Parent) then
    ANode.Parent.Children.Remove(ANode);
end;

procedure TMainViewController.RenameNode(ANode: TXmlNodeItem; const ANewName: string);
begin
  if Assigned(ANode) and (ANode.NodeType in [ntElement, ntAttribute]) then
    ANode.Name := ANewName;
end;

procedure TMainViewController.SetNodeValue(ANode: TXmlNodeItem; const ANewValue: string);
begin
  if Assigned(ANode) and (ANode.NodeType <> ntElement) then
    ANode.Value := ANewValue;
end;

procedure TMainViewController.InsertBefore(ANode: TXmlNodeItem; AType: TXmlNodeType; const AName, AValue: string);
var
  Index: Integer;
  NewNode: TXmlNodeItem;
begin
  if not Assigned(ANode) or not Assigned(ANode.Parent) then Exit;
  Index := ANode.Parent.Children.IndexOf(ANode);
  if Index = -1 then Exit;
  NewNode := TXmlNodeItem.Create(AType);
  NewNode.Parent := ANode.Parent;
  if AType in [ntElement, ntAttribute] then
    NewNode.Name := AName;
  if AType <> ntElement then
    NewNode.Value := AValue;
  ANode.Parent.Children.Insert(Index, NewNode);
end;

procedure TMainViewController.InsertAfter(ANode: TXmlNodeItem; AType: TXmlNodeType; const AName, AValue: string);
var
  Index: Integer;
  NewNode: TXmlNodeItem;
begin
  if not Assigned(ANode) or not Assigned(ANode.Parent) then Exit;
  Index := ANode.Parent.Children.IndexOf(ANode);
  if Index = -1 then Exit;
  NewNode := TXmlNodeItem.Create(AType);
  NewNode.Parent := ANode.Parent;
  if AType in [ntElement, ntAttribute] then
    NewNode.Name := AName;
  if AType <> ntElement then
    NewNode.Value := AValue;
  ANode.Parent.Children.Insert(Index + 1, NewNode);
end;

procedure TMainViewController.LoadFromXml(const Filename: string);
var
  Doc: IXMLDOMDocument;

  function CreateNode(XMLNode: IXMLDOMNode): TXmlNodeItem;
  var
    SubNode: IXMLDOMNode;
    AttrNode: TXmlNodeItem;
    i: Integer;
  begin
    Result := TXmlNodeItem.Create(ntElement);
    Result.Name := XMLNode.nodeName;

    for i := 0 to XMLNode.attributes.length - 1 do
    begin
      AttrNode := TXmlNodeItem.Create(ntAttribute);
      AttrNode.Name := XMLNode.attributes.item[i].nodeName;
      AttrNode.Value := XMLNode.attributes.item[i].text;
      AttrNode.Parent := Result;
      Result.Attributes.Add(AttrNode);
    end;


    for i := 0 to XMLNode.childNodes.length - 1 do
    begin
      SubNode := XMLNode.childNodes.item[i];
      if not Assigned(SubNode) then Continue;

      case SubNode.nodeType of
        NODE_ELEMENT:
          Result.Children.Add(CreateNode(SubNode));
        NODE_TEXT:
          if Trim(SubNode.text) <> '' then
            AddChild(Result, ntText, '', SubNode.text);
        NODE_CDATA_SECTION:
          AddChild(Result, ntCData, '', SubNode.text);
        NODE_COMMENT:
          AddChild(Result, ntComment, '', SubNode.text);
      else
        // unsupported node types ignored
      end;
    end;
  end;

begin
  Doc := CoDOMDocument60.Create;
  if not Doc.load(Filename) then
    raise Exception.Create('Could not load file: ' + Filename);

  if not Assigned(Doc.documentElement) then
    raise Exception.Create('Invalid XML file: missing document element.');

  FRootNode.Free;
  FRootNode := CreateNode(Doc.documentElement);
end;

procedure TMainViewController.SaveToXml(const Filename: string);
var
  Doc: IXMLDOMDocument;

  procedure SaveNode(Node: TXmlNodeItem; Parent: IXMLDOMElement);
  var
    NewElem: IXMLDOMElement;
    i: Integer;
    Child: TXmlNodeItem;
  begin
    // Save attributes of this node
    for i := 0 to Node.Attributes.Count - 1 do
      Parent.setAttribute(Node.Attributes[i].Name, Node.Attributes[i].Value);

    // Save children (elements, text, comments, etc.)
    for i := 0 to Node.Children.Count - 1 do
    begin
      Child := Node.Children[i];
      case Child.NodeType of
        ntElement:
          begin
            NewElem := Doc.createElement(Child.Name);
            Parent.appendChild(NewElem);
            SaveNode(Child, NewElem); // Recurse
          end;
        ntText:
          Parent.appendChild(Doc.createTextNode(Child.Value));
        ntCData:
          Parent.appendChild(Doc.createCDATASection(Child.Value));
        ntComment:
          Parent.appendChild(Doc.createComment(Child.Value));
      end;
    end;
  end;

var
  RootElem: IXMLDOMElement;
begin
  Doc := CoDOMDocument60.Create;
  Doc.async := False;
  Doc.validateOnParse := False;

  // Create root element from FRootNode
  RootElem := Doc.createElement(FRootNode.Name);
  Doc.appendChild(RootElem);

  // Save structure recursively
  SaveNode(FRootNode, RootElem);

  // Save file
  Doc.save(Filename);
end;


end.

