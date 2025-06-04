unit XML.MainModel;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections;

type
  ///<summary>Enum f&uuml;r die Typen von XML-Knoten.</summary>
  TXmlNodeType = (ntElement, ntAttribute, ntText, ntCData, ntComment);

  ///<summary>
  /// Die Klasse stellt ein einzelnes XML-Knotenobjekt dar. Abh&auml;ngig vom
  /// Knotentyp (ntElement, ntAttribute, etc.) enth&auml;lt es optional Namen,
  /// Wert, Attribute oder Kindknoten.
  ///</summary>
  TXmlNodeItem = class(TObject)
  private
    FNodeType: TXmlNodeType;
    FName: string;
    FValue: string;
    FChildren: TObjectList<TXmlNodeItem>;
    FAttributes: TObjectList<TXmlNodeItem>;
    FParent: TXmlNodeItem;
    FOnChange: TNotifyEvent;
    procedure FireOnChange;
    procedure SetValue(const AValue: string);
    function GetHasParent: Boolean;
  public
    ///<summary>Konstruktor, initialisiert je nach Typ die Listen.</summary>
    constructor Create(ANodeType: TXmlNodeType);
    ///<summary>Destruktor, gibt Ressourcen frei.</summary>
    destructor Destroy; override;

    ///<summary>Typ des Knotens (Element, Attribut, etc.).</summary>
    property NodeType: TXmlNodeType read FNodeType;
    ///<summary>Name des Knotens, sofern definiert.</summary>
    property Name: string read FName write FName;
    ///<summary>Wert des Knotens, sofern zutreffend.</summary>
    property Value: string read FValue write SetValue;
    ///<summary>Liste von Kindknoten (nur f&uuml;r ntElement).</summary>
    property Children: TObjectList<TXmlNodeItem> read FChildren;
    ///<summary>Liste von Attributen (nur f&uuml;r ntElement).</summary>
    property Attributes: TObjectList<TXmlNodeItem> read FAttributes;
    ///<summary>Referenz zum Elternknoten (optional).</summary>
    property Parent: TXmlNodeItem read FParent write FParent;
    ///<summary>Gibt true zur&uuml;ck, wenn Parent gesetzt ist.</summary>
    property HasParent: Boolean read GetHasParent;
    ///<summary>Event, wenn sich Eigenschaften &auml;ndern.</summary>
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

implementation

//------------------------------------------------------------------------------
constructor TXmlNodeItem.Create(ANodeType: TXmlNodeType);
begin
  inherited Create;
  FNodeType := ANodeType;

  if FNodeType = ntElement then
  begin
    FChildren := TObjectList<TXmlNodeItem>.Create;
    FAttributes := TObjectList<TXmlNodeItem>.Create;
  end
  else
  begin
    FChildren := nil;
    FAttributes := nil;
  end;
end;

//------------------------------------------------------------------------------
destructor TXmlNodeItem.Destroy;
begin
  FreeAndNil(FChildren);
  FreeAndNil(FAttributes);
  inherited;
end;

//------------------------------------------------------------------------------
procedure TXmlNodeItem.FireOnChange;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

//------------------------------------------------------------------------------
procedure TXmlNodeItem.SetValue(const AValue: string);
begin
  if FValue <> AValue then
  begin
    FValue := AValue;
    FireOnChange;
  end;
end;

//------------------------------------------------------------------------------
function TXmlNodeItem.GetHasParent: Boolean;
begin
  Result := Assigned(FParent);
end;

end.

