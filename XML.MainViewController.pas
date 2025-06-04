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
  if AType in [ntElement, ntAttribute] then
    Result.Name := AName;
  if AType <> ntElement then
    Result.Value := AValue;
  if Assigned(AParent) then
    AParent.Children.Add(Result);
end;

function TMainViewController.AddAttribute(AParent: TXmlNodeItem; const AName, AValue: string): TXmlNodeItem;
begin
  Result := AddChild(AParent, ntAttribute, AName, AValue);
end;

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
    i: Integer;
  begin
    Result := TXmlNodeItem.Create(ntElement);
    Result.Name := XMLNode.nodeName;

    for i := 0 to XMLNode.attributes.length - 1 do
    begin
      Result.Children.Add(TXmlNodeItem.Create(ntAttribute));
      Result.Children.Last.Name := XMLNode.attributes.item[i].nodeName;
      Result.Children.Last.Value := XMLNode.attributes.item[i].text;
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
            Result.Children.Add(AddChild(Result, ntText, '', SubNode.text));
        NODE_CDATA_SECTION:
          Result.Children.Add(AddChild(Result, ntCData, '', SubNode.text));
        NODE_COMMENT:
          Result.Children.Add(AddChild(Result, ntComment, '', SubNode.text));
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
  begin
    for i := 0 to Node.Children.Count - 1 do
    begin
      case Node.Children[i].NodeType of
        ntAttribute:
          Parent.setAttribute(Node.Children[i].Name, Node.Children[i].Value);
        ntElement:
          begin
            NewElem := Doc.createElement(Node.Children[i].Name);
            Parent.appendChild(NewElem);
            SaveNode(Node.Children[i], NewElem);
          end;
        ntText:
          Parent.appendChild(Doc.createTextNode(Node.Children[i].Value));
        ntCData:
          Parent.appendChild(Doc.createCDATASection(Node.Children[i].Value));
        ntComment:
          Parent.appendChild(Doc.createComment(Node.Children[i].Value));
      end;
    end;
  end;

begin
  Doc := CoDOMDocument60.Create;
  Doc.loadXML(Format('<?xml version="1.0" encoding="UTF-8"?><%s/>', [FRootNode.Name]));
  SaveNode(FRootNode, Doc.documentElement);
  Doc.save(Filename);
end;

end.

