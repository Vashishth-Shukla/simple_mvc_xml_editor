unit XML.MainViewController;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,

  XML.MainModel;

type
  ///<summary>
  /// Die zentrale Steuerungsklasse für die XML-Editor-Oberfläche.
  /// Verwaltet das XML-Datenmodell (RootNode) und bietet Operationen
  /// zur Bearbeitung und Persistenz.
  ///</summary>
  TMainViewController = class
  private
    ///<summary>Wurzelelement des aktuellen XML-Dokuments.</summary>
    FRootNode: TXmlNodeItem;
  public
    ///<summary>Initialisiert die View-Controller-Instanz und erzeugt einen leeren Root-Knoten.</summary>
    constructor Create;

    ///<summary>Gibt belegte Ressourcen frei.</summary>
    destructor Destroy; override;

    ///<summary>Löscht das aktuelle XML-Modell und erzeugt einen neuen leeren Root-Knoten.</summary>
    procedure Clear;

    ///<summary>
    /// Fügt einem XML-Knoten ein neues Kind hinzu.
    ///</summary>
    ///<param name="AParent">Das Elternelement, zu dem das Kind hinzugefügt wird.</param>
    ///<param name="AType">Typ des neuen Knotens (Element, Text, Kommentar etc.).</param>
    ///<param name="AName">Name des neuen Knotens.</param>
    ///<param name="AValue">Wert des neuen Knotens (sofern zutreffend).</param>
    ///<returns>Der neu hinzugefügte Knoten.</returns>
    function AddChild(AParent: TXmlNodeItem; AType: TXmlNodeType; const AName, AValue: string): TXmlNodeItem;

    ///<summary>
    /// Fügt einem Elementknoten ein neues Attribut hinzu.
    ///</summary>
    ///<param name="AParent">Das Ziel-Element, dem das Attribut hinzugefügt wird.</param>
    ///<param name="AName">Name des Attributs.</param>
    ///<param name="AValue">Wert des Attributs.</param>
    ///<returns>Das neu erstellte Attribut als Knoten.</returns>
    function AddAttribute(AParent: TXmlNodeItem; const AName, AValue: string): TXmlNodeItem;

    ///<summary>Entfernt den angegebenen Knoten aus dem XML-Modell.</summary>
    ///<param name="ANode">Der zu entfernende Knoten.</param>
    procedure DeleteNode(ANode: TXmlNodeItem);

    ///<summary>Ändert den Namen eines Elements oder Attributs.</summary>
    ///<param name="ANode">Der umzubenennende Knoten.</param>
    ///<param name="ANewName">Der neue Name.</param>
    procedure RenameNode(ANode: TXmlNodeItem; const ANewName: string);

    ///<summary>Setzt den Wert eines Text-, Kommentar-, CDATA- oder Attribut-Knotens.</summary>
    ///<param name="ANode">Der Zielknoten.</param>
    ///<param name="ANewValue">Der neue Wert.</param>
    procedure SetNodeValue(ANode: TXmlNodeItem; const ANewValue: string);

    ///<summary>
    /// Fügt ein neues Element vor einem existierenden Knoten ein.
    ///</summary>
    ///<param name="ANode">Der Referenzknoten, vor dem eingefügt wird.</param>
    ///<param name="AType">Typ des neuen Knotens.</param>
    ///<param name="AName">Name des neuen Knotens.</param>
    ///<param name="AValue">Wert des neuen Knotens.</param>
    procedure InsertBefore(ANode: TXmlNodeItem; AType: TXmlNodeType;
      const AName, AValue: string);

    ///<summary>
    /// Fügt ein neues Element nach einem existierenden Knoten ein.
    ///</summary>
    ///<param name="ANode">Der Referenzknoten, nach dem eingefügt wird.</param>
    ///<param name="AType">Typ des neuen Knotens.</param>
    ///<param name="AName">Name des neuen Knotens.</param>
    ///<param name="AValue">Wert des neuen Knotens.</param>
    procedure InsertAfter(ANode: TXmlNodeItem; AType: TXmlNodeType;
      const AName, AValue: string);

    ///<summary>Lädt ein XML-Dokument von einer Datei und erstellt das entsprechende Modell.</summary>
    ///<param name="Filename">Pfad zur XML-Datei.</param>
    procedure LoadFromXml(const Filename: string);

    ///<summary>Speichert das aktuelle XML-Modell in eine Datei.</summary>
    ///<param name="Filename">Zielpfad für die XML-Datei.</param>
    procedure SaveToXml(const Filename: string);

    ///<summary>Der aktuelle Root-Knoten des XML-Dokuments.</summary>
    property RootNode: TXmlNodeItem read FRootNode;
  end;


implementation

uses
  Winapi.msxml;

//------------------------------------------------------------------------------
//                            Constructor / Destructor
//------------------------------------------------------------------------------

constructor TMainViewController.Create;
begin
  inherited;
  Clear;
end;

//------------------------------------------------------------------------------
destructor TMainViewController.Destroy;
begin
  FRootNode.Free;
  inherited;
end;

//------------------------------------------------------------------------------
procedure TMainViewController.Clear;
begin
  FRootNode.Free;
  FRootNode := TXmlNodeItem.Create(ntElement);
  FRootNode.Name := 'root';
end;

//------------------------------------------------------------------------------
//                          Node Creation & Modification
//------------------------------------------------------------------------------

function TMainViewController.AddChild(AParent: TXmlNodeItem; AType: TXmlNodeType;
  const AName, AValue: string): TXmlNodeItem;
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

//------------------------------------------------------------------------------
function TMainViewController.AddAttribute(AParent: TXmlNodeItem; const AName,
  AValue: string): TXmlNodeItem;
begin
  Result := AddChild(AParent, ntAttribute, AName, AValue);
end;

//------------------------------------------------------------------------------
procedure TMainViewController.DeleteNode(ANode: TXmlNodeItem);
begin
  if Assigned(ANode) and Assigned(ANode.Parent) then
    ANode.Parent.Children.Remove(ANode);
end;

//------------------------------------------------------------------------------
procedure TMainViewController.RenameNode(ANode: TXmlNodeItem; const ANewName: string);
begin
  if Assigned(ANode) and (ANode.NodeType in [ntElement, ntAttribute]) then
    ANode.Name := ANewName;
end;

//------------------------------------------------------------------------------
procedure TMainViewController.SetNodeValue(ANode: TXmlNodeItem; const ANewValue: string);
begin
  if Assigned(ANode) and (ANode.NodeType <> ntElement) then
    ANode.Value := ANewValue;
end;

//------------------------------------------------------------------------------
procedure TMainViewController.InsertBefore(ANode: TXmlNodeItem; AType: TXmlNodeType;
  const AName, AValue: string);
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

//------------------------------------------------------------------------------
procedure TMainViewController.InsertAfter(ANode: TXmlNodeItem; AType: TXmlNodeType;
  const AName, AValue: string);
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

//------------------------------------------------------------------------------
//                            File I/O (XML Persistence)
//------------------------------------------------------------------------------

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
            SaveNode(Child, NewElem);
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

  RootElem := Doc.createElement(FRootNode.Name);
  Doc.appendChild(RootElem);

  SaveNode(FRootNode, RootElem);
  Doc.save(Filename);
end;


end.

