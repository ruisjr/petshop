unit Core.Entidades.ModelBase;

interface

Uses
   System.Rtti
  ,System.TypInfo
  ,System.Generics.Collections;

type
  TBaseModel = class
  private
  public
    destructor Destroy; override;

    procedure Clear;
    function ToStrings: String; reintroduce;
  end;

implementation

{ TBaseModel }

procedure TBaseModel.Clear;
var
  vCtx: TRttiContext;
  vType: TRttiType;
  vProp: TRttiProperty;
  vPropValue: TValue;
  vRttiMethod: TRttiMethod;
begin
  vCtx := TRttiContext.Create;
  try
    vType := vCtx.GetType(Self.ClassType);
    for vProp in vType.GetProperties do
    begin
      if vProp.IsWritable then
      begin
        case vProp.PropertyType.TypeKind of
          tkInteger, tkInt64, tkFloat:
            vProp.SetValue(Self, nil);
          tkString, tkUString, tkLString, tkWString:
            vProp.SetValue(Self, nil);
          tkEnumeration:
            if vProp.PropertyType.Handle = TypeInfo(Boolean) then
              vProp.SetValue(Self, False)
            else
              vProp.SetValue(Self, nil);
          tkClass:
            if vProp <> nil then
            begin
              vPropValue := vProp.GetValue(Self);
              if (not vPropValue.IsEmpty) then
              begin
                vRttiMethod := (vProp.PropertyType as TRttiInstanceType).GetMethod('Clear');
              if Assigned(vRttiMethod) then
                vRttiMethod.Invoke(vPropValue.AsObject, []);
              end;
            end
            else
              vProp.SetValue(Self, nil);
        end;
      end;
    end;
  finally
    vCtx.Free;
  end;
end;

destructor TBaseModel.Destroy;
var
  LCtx: TRttiContext;
  LType: TRttiType;
  LprpRtti: TRttiProperty;
  LPropValue: TValue;
begin
  LCtx := TRttiContext.Create;
  try
    LType := LCtx.GetType(Self.ClassType);
    for LprpRtti in LType.GetProperties do
    begin
      if LprpRtti.PropertyType.TypeKind = tkClass then
      begin
        if LprpRtti.PropertyType.IsInstance then
        begin
          LPropValue := LprpRtti.GetValue(Self);
          if (LPropValue.AsObject <> nil) then
          begin
            LPropValue.AsObject.Free;
          end
        end;
      end;
    end;
  finally
    LCtx.Free;
  end;
end;

function TBaseModel.ToStrings: String;
var
  LCtx: TRttiContext;
  LType: TRttiType;
  LProp: TRttiProperty;
  LText: String;
begin
  LText := 'Class: ' + Self.ClassName + #13#10;
  LCtx := TRttiContext.Create;
  try
    LType := LCtx.GetType(Self.ClassType);
    for LProp in LType.GetProperties do
      LText := LText + 'Property: ' + LProp.Name + #13#10;
  finally
    LCtx.Free;
  end;
  Result := LText;
end;

end.
