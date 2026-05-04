unit Core.DataBase.Rtti;

interface

uses
  //Classes de sistema
   Data.Db
  ,AdvEdit
  ,Advcombo
  ,Vcl.Forms
  ,System.Rtti
  ,System.JSON
  ,Vcl.ExtCtrls
  ,System.TypInfo
  ,System.Classes
  ,System.SysUtils
  ,System.Variants
  ,AdvOfficeButtons
  ,System.Generics.Collections
  //Classes de negócio
  ,Core.DataBase.Types
  ,Core.DataBase.RttiHelper
  ,Core.DataBase.Interfaces
  ,Core.Entidades.CustomAttributes;

type
  EDataBaseRtti = Exception;

  TDataBaseRtti<T : class, constructor> = class(TInterfacedObject, IDataBaseRtti<T>)
  strict private
    function ValueIsNil(const pValue: TValue): Boolean;
  private
    FInstance : T;
    FModeInsert: Boolean;

    function _CreateObjectByName(const AClassName: string): T;
    function _FloatFormat(pValue: String): Currency;
    function _BindValueToComponent(pComponent: TComponent; pValue : Variant): IDataBaseRtti<T>;
    function _BindValueToProperty(pEntity: T; pProperty: TRttiProperty; pValue : TValue): IDataBaseRtti<T>;
    function _GetRttiProperty(pEntity: T; pPropertyName: String): TRttiProperty;
    function _GetRttiPropertyValue(pEntity: T; pPropertyName: String): Variant;
    function _GetComponentToValue(pComponent: TComponent): TValue;
  public
    {Construtores e Destrutores}
    constructor Create(pInstance: T);
    destructor Destroy; override;

    { Funções de classes }
    class function New(pInstance: T): IDataBaseRtti<T>;

    {Funções}
    function TableName(var pTableName: String): IDataBaseRtti<T>;
    function Sequence(var pSequence: String): IDataBaseRtti<T>;
    function ClassName(var pClassName: String): IDataBaseRtti<T>;
    function Fields(var pFields: String): IDataBaseRtti<T>;
    function FieldsInsert(var aFields: String): IDataBaseRtti<T>;
    function Param(var pParam: String): IDataBaseRtti<T>;
    function Where(var pWhere: String): IDataBaseRtti<T>;
    function Update(var pUpdate: String): IDataBaseRtti<T>;
    function Values(pInstance: T; var pValues: String): IDataBaseRtti<T>;

    function DataSetToEntity(pDataSet: TDataSet; out pEntity: T): IDataBaseRtti<T>;
    function DataSetToEntityList(vDataSet: TDataSet; var vList: TObjectList<T>): IDataBaseRtti<T>;

    function DictionaryFields(var pDictionary: TDictionary<string, variant>): IDataBaseRtti<T>;
    function DictionaryTypeFields(const pParameters: TDictionary<string, TValue>; var aDictionary: TDictionary<string, TFieldType>): IDataBaseRtti<T>; overload;
    function DictionaryTypeFields(var aDictionary: TDictionary<string, TFieldType>): IDataBaseRtti<T>; overload;
    function BindFormToEntity(pForm : TForm; var pEntity: T): IDataBaseRtti<T>;
    function BindEntityToForm(pForm : TForm; const pEntity: T): IDataBaseRtti<T>;
  end;



implementation

Uses
  Vcl.StdCtrls;

{ TDataBaseRtti<T> }

function TDataBaseRtti<T>.BindEntityToForm(pForm: TForm; const pEntity: T): IDataBaseRtti<T>;
var
  vTypRtti: TRttiType;
  vPrpRtti: TRttiField;
  vCtxRtti: TRttiContext;
begin
  Result := Self;

  vCtxRtti := TRttiContext.Create;
  try
    vTypRtti := vCtxRtti.GetType(pForm.ClassInfo);
    for vPrpRtti in vTypRtti.GetFields do
    begin
      if vPrpRtti.Has<Bind> then
        _BindValueToComponent(pForm.FindComponent(vPrpRtti.Name), _GetRttiPropertyValue(pEntity, vPrpRtti.GetAttribute<Bind>.Field));
    end;
  finally
    vCtxRtti.Free;
  end;
end;

function TDataBaseRtti<T>.BindFormToEntity(pForm: TForm; var pEntity: T): IDataBaseRtti<T>;
var
  vTypRtti: TRttiType;
  vPrpRtti: TRttiField;
  vCtxRtti: TRttiContext;
begin
  Result := Self;
  vCtxRtti := TRttiContext.Create;
  try
    vTypRtti := vCtxRtti.GetType(pForm.ClassInfo);
    for vPrpRtti in vTypRtti.GetFields do
    begin
      if vPrpRtti.Has<Bind> then
      begin
        _BindValueToProperty(pEntity, _GetRttiProperty(pEntity, vPrpRtti.GetAttribute<Bind>.Field), _GetComponentToValue(pForm.FindComponent(vPrpRtti.Name)));
      end;
    end;
  finally
    vCtxRtti.Free;
  end;
end;

function TDataBaseRtti<T>.ClassName(var pClassName: String): IDataBaseRtti<T>;
var
  vTypRtti: TRttiType;
  vCtxRtti: TRttiContext;
begin
  Result := Self;
  vCtxRtti := TRttiContext.Create;
  try
    vTypRtti := vCtxRtti.GetType(FInstance.ClassInfo);
    pClassName := Copy(vTypRtti.Name, 2, Length(vTypRtti.Name));
  finally
    vCtxRtti.Free;
  end;
end;

constructor TDataBaseRtti<T>.Create(pInstance: T);
begin
  FInstance := pInstance;
  FModeInsert := False;
end;

function TDataBaseRtti<T>._CreateObjectByName(const AClassName: string): T;
var
  LContext: TRttiContext;
  LType: TRttiInstanceType;
  LConstructor: TRttiMethod;
  LFullClassName: string;
begin
  Result := nil;

  if Pos('.', AClassName) = 0 then
    LFullClassName := FInstance.UnitName + '.' +AClassName
  else
    LFullClassName := AClassName;

  LContext := TRttiContext.Create;
  try
    LType := LContext.FindType(LFullClassName) as TRttiInstanceType;

    if Assigned(LType) then
    begin
      LConstructor := LType.GetMethod('Create');
      if Assigned(LConstructor) then
      begin
        Result := LConstructor.Invoke(LType.MetaclassType, []).AsType<T>;
      end
      else
        raise Exception.Create('Construtor "Create" sem parâmetros não encontrado para ' + LFullClassName);
    end
    else
      raise Exception.Create('Classe não encontrada: ' + LFullClassName);

  finally
    LContext.Free;
  end;
end;

function TDataBaseRtti<T>.DataSetToEntity(pDataSet: TDataSet; out pEntity: T): IDataBaseRtti<T>;
var
  vObj: TObject;
  vValue: TValue;
  vField : TField;
  vCtxRtti: TRttiContext;
  vTypRtti: TRttiType;
  vprpRtti,
  vPrpFKType: TRttiProperty;
  vMemoryStream: TMemoryStream;
begin
  Result := Self;
  pEntity := _CreateObjectByName(FInstance.ClassType.ClassName);
  pDataSet.First;
  while not pDataSet.Eof do
  begin
    vCtxRtti := TRttiContext.Create;
    try
      for vField in pDataSet.Fields do
      begin
        vTypRtti := vCtxRtti.GetType(FInstance.Classtype);
        for vprpRtti in vTypRtti.GetProperties do
        begin
          if LowerCase(vprpRtti.FieldName) = LowerCase(vField.DisplayName) then
          begin
            case vprpRtti.PropertyType.TypeKind of
              tkUnknown, tkString, tkWChar, tkLString, tkWString, tkUString:
                vValue := vField.AsString;
              tkInteger, tkInt64:
                vValue := vField.AsInteger;
              tkChar: ;
              tkEnumeration:
              begin
                if (vprpRtti.GetValue(Pointer(pEntity)).TypeInfo = TypeInfo(Boolean)) then
                  vValue := vField.AsBoolean
                else
                  vValue := vField.AsString;
              end;
              tkFloat:
              begin
                if ((vprpRtti.GetValue(Pointer(pEntity)).TypeInfo = TypeInfo(TDate)) or
                    (vprpRtti.GetValue(Pointer(pEntity)).TypeInfo = TypeInfo(TDateTime))) then
                  vValue := vField.AsDateTime
                else
                  vValue := vField.AsFloat;
              end;
              tkSet: ;
              tkClass:
              begin
                if vprpRtti.IsForeignKey then
                begin
                  vObj := vprpRtti.GetValue(Pointer(pEntity)).AsObject;
                  vPrpFKType := vprpRtti.GetFKField(vObj);
                  if vPrpFKType <> nil then
                    vValue := vObj;
                end
                else
                begin
                  if vprpRtti.GetValue(Pointer(pEntity)).TypeInfo = TypeInfo(TJSONObject) then
                  begin
                    vValue := TJSONObject(TJSONObject.ParseJSONValue(vField.AsString));
                    vprpRtti.SetValue(Pointer(pEntity), vValue);
                  end
                  else if vprpRtti.GetValue(Pointer(pEntity)).TypeInfo = TypeInfo(TJSONArray) then
                  begin
                    vValue := TJSONArray(TJSONObject.ParseJSONValue(vField.AsString));
                    vprpRtti.SetValue(Pointer(pEntity), vValue);
                  end
                  else if (vprpRtti.GetValue(Pointer(pEntity)).TypeInfo = TypeInfo(TMemoryStream)) then
                  begin
                    TBlobField(vField).SaveToStream(vMemoryStream);
                    if vMemoryStream <> nil then
                    begin
                      vMemoryStream.Position := 0;
                      vprpRtti.SetValue(Pointer(pEntity), vMemoryStream);
                    end;
                  end;
                end;
              end;
              tkMethod: ;
              tkVariant: ;
              tkArray: ;
              tkRecord: ;
              tkInterface: ;
              tkDynArray: ;
              tkClassRef: ;
              tkPointer: ;
              tkProcedure: ;
            end;
            if VPrpRtti.PropertyType.TypeKind <> tkClass then
              vprpRtti.SetValue(Pointer(pEntity), vValue);
          end;
        end;
      end;
    finally
      vCtxRtti.Free;
    end;
    pDataSet.Next;
  end;
  pDataSet.First;
end;

function TDataBaseRtti<T>.DataSetToEntityList(vDataSet: TDataSet; var vList: TObjectList<T>): IDataBaseRtti<T>;
var
  vInfo: PTypeInfo;
  vValue: TValue;
  vField: TField;
  vCtxRtti: TRttiContext;
  VPrpRtti: TRttiProperty;
begin
  Result := Self;
  vList.Clear;
  while not vDataSet.Eof do
  begin
    vInfo := System.TypeInfo(T);
    vList.Add(T.Create);
    vCtxRtti := TRttiContext.Create;
    try
      for vField in vDataSet.Fields do
      begin
        for VPrpRtti in vCtxRtti.GetType(vInfo).GetProperties do
        begin
          if LowerCase(vPrpRtti.FieldName) = LowerCase(vField.FieldName) then
          begin
            vField.DisplayLabel := VPrpRtti.DisplayName;
            case VPrpRtti.PropertyType.TypeKind of
              tkUnknown, tkString, tkWChar, tkLString, tkWString, tkUString:
                vValue := vField.AsString;
              tkInteger, tkInt64:
                vValue := vField.AsInteger;
              tkChar: ;
              tkEnumeration:
              begin
                if (VPrpRtti.GetValue(vInfo).TypeInfo.Name = 'Boolean') then
                  vValue := vField.AsBoolean
                else
                  vValue := vField.AsString;
              end;
              tkFloat:
                vValue := vField.AsFloat;
              tkSet: ;
              tkClass: ;
              tkMethod: ;
              tkVariant: ;
              tkArray: ;
              tkRecord: ;
              tkInterface: ;
              tkDynArray: ;
              tkClassRef: ;
              tkPointer: ;
              tkProcedure: ;
            end;
            if VPrpRtti.PropertyType.TypeKind <> tkClass then
              VPrpRtti.SetValue(Pointer(vList[Pred(vList.Count)]), vValue);
          end;
        end;
      end;
    finally
      vCtxRtti.Free;
    end;
    vDataSet.Next;
  end;
  vDataSet.Close;
end;

destructor TDataBaseRtti<T>.Destroy;
begin

  inherited;
end;

function TDataBaseRtti<T>.DictionaryFields(var pDictionary: TDictionary<string, variant>): IDataBaseRtti<T>;
var
  Ptr: Pointer;
  aObj: TObject;
  typRtti: TRttiType;
  ctxRtti: TRttiContext;
  prpRtti,
  prpFKType: TRttiProperty;
  vVariant: Variant;
  mmStream: TMemoryStream;
begin
  Result  := Self;
  ctxRtti := TRttiContext.Create;
  try
    typRtti := ctxRtti.GetType(FInstance.classInfo);
    for prpRtti in typRtti.GetProperties do
    begin
      if not prpRtti.IsNotNull and prpRtti.IsIgnore then
        Continue;

      case prpRtti.PropertyType.TypeKind of
        tkInteger, tkInt64:
        begin
          if prpRtti.IsPrimaryKey or prpRtti.IsForeignKey then
          begin
            if prpRtti.IsSequence and FModeInsert then
              continue
            else
              pDictionary.Add(prpRtti.FieldName, prpRtti.GetValue(Pointer(FInstance)).AsInteger);
          end
          else
            pDictionary.Add(prpRtti.FieldName, prpRtti.GetValue(Pointer(FInstance)).AsInteger);
          end;
        tkFloat:
        begin
          if (prpRtti.GetValue(Pointer(FInstance)).TypeInfo = TypeInfo(TDateTime)) or
             (prpRtti.GetValue(Pointer(FInstance)).TypeInfo = TypeInfo(TDate)) or
             (prpRtti.GetValue(Pointer(FInstance)).TypeInfo = TypeInfo(TTime)) then
          begin
            if prpRtti.GetValue(Pointer(FInstance)).AsExtended = 0 then
                pDictionary.Add(prpRtti.FieldName, Null)
            else
            begin
              if prpRtti.GetValue(Pointer(FInstance)).TypeInfo = TypeInfo(TDate) then
                pDictionary.Add(prpRtti.FieldName, StrToDate(prpRtti.GetValue(Pointer(FInstance)).ToString))
              else if prpRtti.GetValue(Pointer(FInstance)).TypeInfo = TypeInfo(TTime) then
                pDictionary.Add(prpRtti.FieldName, StrToTime(prpRtti.GetValue(Pointer(FInstance)).ToString))
              else
                pDictionary.Add(prpRtti.FieldName, StrToDateTime(prpRtti.GetValue(Pointer(FInstance)).ToString ));
            end;
          end
          else
              pDictionary.Add(prpRtti.FieldName, _FloatFormat(prpRtti.GetValue(Pointer(FInstance)).ToString));
        end;
        tkWChar,
        tkLString,
        tkWString,
        tkUString,
        tkString:
          pDictionary.Add(prpRtti.FieldName, prpRtti.GetValue(Pointer(FInstance)).AsString);
        tkVariant:
          pDictionary.Add(prpRtti.FieldName, prpRtti.GetValue(Pointer(FInstance)).AsVariant);
        tkClass:
        begin
          if prpRtti.IsForeignKey then
          begin
            if prpRtti.GetValue(Pointer(FInstance)).AsInteger = 0 then
              Continue;

            aObj := prpRtti.GetValue(Pointer(FInstance)).AsObject;
            prpFKType := prpRtti.GetFKField(aObj);

            if (prpFKType <> nil) and (prpFKType.getValue(aObj).asInteger = 0) then
              Continue;

            if (prpFKType <> nil) then
              pDictionary.Add(prpRtti.fieldname, prpFKType.getValue(aObj).asinteger)
          end
          else
          begin
            if prpRtti.PropertyType.Handle = TypeInfo(TJSONArray) then
              pDictionary.Add(prpRtti.FieldName, TJsonArray(prpRtti.GetValue(Pointer(FInstance)).AsObject).ToJSON)
            else if prpRtti.PropertyType.Handle = TypeInfo(TJSONObject) then
              pDictionary.Add(prpRtti.FieldName, TJSONObject(prpRtti.GetValue(Pointer(FInstance)).AsObject).ToJSON)
            else if prpRtti.PropertyType.Handle = TypeInfo(TMemoryStream) then
            begin
              mmStream := TMemoryStream(prpRtti.GetValue(Pointer(FInstance)).AsObject);
              mmStream.Position := 0;
              vVariant := VarArrayCreate([0, mmStream.Size - 1], varByte);
              Ptr := VarArrayLock(vVariant);
              try
                mmStream.Read(Ptr^, mmStream.Size);
              finally
                VarArrayUnlock(vVariant);
              end;

              pDictionary.Add(prpRtti.FieldName, vVariant);
            end;
          end;
        end;
        tkEnumeration:
          if (prpRtti.GetValue(Pointer(FInstance)).TypeInfo.Name = 'Boolean') then
            pDictionary.Add(prpRtti.fieldname, prpRtti.GetValue(Pointer(FInstance)).AsBoolean)
      else
          pDictionary.Add(prpRtti.FieldName, prpRtti.GetValue(Pointer(FInstance)).AsString);
      end;
    end;
  finally
    ctxRtti.Free;
  end;
end;

function TDataBaseRtti<T>.DictionaryTypeFields(const pParameters: TDictionary<string, TValue>; var aDictionary: TDictionary<string, TFieldType>): IDataBaseRtti<T>;
var
  key: String;
begin
  Result := Self;
  for Key in pParameters.Keys do
  begin
    case pParameters.Items[key].Kind of
      tkInteger, tkInt64:
        aDictionary.Add(key, TFieldType.ftInteger);
      tkFloat:
      begin
        if ((pParameters.Items[key].TypeInfo = TypeInfo(TDateTime)) or pParameters.Items[key].IsType<TDateTime>) then
          aDictionary.Add(key, TFieldType.ftDateTime)
        else if ((pParameters.Items[key].TypeInfo = TypeInfo(TDate)) or pParameters.Items[key].IsType<TDate>) then
          aDictionary.Add(key, TFieldType.ftDate)
        else if ((pParameters.Items[key].TypeInfo = TypeInfo(TTime)) or pParameters.Items[key].IsType<TTime>) then
          aDictionary.Add(key, TFieldType.ftTime)
        else
          aDictionary.Add(key, TFieldType.ftFloat)
      end;
      tkWChar,
        tkLString,
        tkWString,
        tkUString:
          aDictionary.Add(key, TFieldType.ftString);
        tkEnumeration:
          if (pParameters.Items[key].TypeInfo.Name = 'Boolean') then
            aDictionary.Add(key, TFieldType.ftBoolean);
    end;
  end;
end;

function TDataBaseRtti<T>.DictionaryTypeFields(var aDictionary: TDictionary<string, TFieldType>): IDataBaseRtti<T>;
var
  ctxRtti   : TRttiContext;
  typRtti   : TRttiType;
  prpRtti   : TRttiProperty;
begin
  Result := Self;
  ctxRtti := TRttiContext.Create;
  try
    typRtti := ctxRtti.GetType(FInstance.ClassInfo);
    for prpRtti in typRtti.GetProperties do
    begin
      if not prpRtti.IsNotNull and prpRtti.IsIgnore then
        Continue;

      if ValueIsNil(prpRtti.GetValue(Pointer(FInstance))) then
      Continue;

      case prpRtti.PropertyType.TypeKind of
        tkInteger, tkInt64:
          aDictionary.Add(prpRtti.FieldName, TFieldType.ftInteger);
        tkFloat:
        begin
          if prpRtti.GetValue(Pointer(FInstance)).TypeInfo = TypeInfo(TDateTime) then
              aDictionary.Add(prpRtti.FieldName, TFieldType.ftDateTime)
          else if prpRtti.GetValue(Pointer(FInstance)).TypeInfo = TypeInfo(TDate) then
              aDictionary.Add(prpRtti.FieldName, TFieldType.ftDate)
          else if prpRtti.GetValue(Pointer(FInstance)).TypeInfo = TypeInfo(TTime) then
              aDictionary.Add(prpRtti.FieldName, TFieldType.ftTime)
          else
              aDictionary.Add(prpRtti.FieldName, TFieldType.ftFloat)
        end;
        tkWChar,
        tkLString,
        tkWString,
        tkUString:
          aDictionary.Add(prpRtti.FieldName, TFieldType.ftString);
        tkEnumeration:
          if (prpRtti.GetValue(Pointer(FInstance)).TypeInfo = TypeInfo(Boolean)) then
            aDictionary.Add(prpRtti.FieldName, TFieldType.ftBoolean);
        tkClass:
        begin
          if (prpRtti.PropertyType.Handle = TypeInfo(TJSONArray)) or (prpRtti.PropertyType.Handle = TypeInfo(TJSONObject)) then
            aDictionary.Add(prpRtti.FieldName, TFieldType.ftOraClob)
          else if (prpRtti.PropertyType.Handle = TypeInfo(TMemoryStream)) then
            aDictionary.Add(prpRtti.FieldName, TFieldType.ftBlob)
        end;
      end;
    end;
  finally
    ctxRtti.Free;
  end;
end;

function TDataBaseRtti<T>.Fields(var pFields: String): IDataBaseRtti<T>;
var
  vCtxRtti : TRttiContext;
  vTypRtti : TRttiType;
  vPrpRtti : TRttiProperty;
begin
  Result   := Self;
  vCtxRtti := TRttiContext.Create;
  try
    vTypRtti := vCtxRtti.GetType(FInstance.ClassInfo);
    for vPrpRtti in vTypRtti.GetProperties do
    begin
      if not vPrpRtti.IsIgnore then
        pFields := pFields + vPrpRtti.FieldName + ', ';
    end;
  finally
    pFields := Copy(pFields, 0, Length(pFields) - 2) + ' ';
    vCtxRtti.Free;
  end;
end;

function TDataBaseRtti<T>.FieldsInsert(var aFields: String): IDataBaseRtti<T>;
var
  vObj      : TObject;
  vCtxRtti  : TRttiContext;
  vTypRtti  : TRttiType;
  vPrpRtti,
  vPrpFKType: TRttiProperty;
begin
  Result   := Self;

  FModeInsert := True;
  vCtxRtti    := TRttiContext.Create;
  try
    vTypRtti := vCtxRtti.GetType(FInstance.ClassInfo);
    for vPrpRtti in vTypRtti.GetProperties do
    begin
//      if vPrpRtti.IsAutoInc then
//        Continue;

      if vPrpRtti.IsIgnore then
        Continue;

      if vPrpRtti.IsForeignKey then
      begin
        begin
          if vPrpRtti.GetValue(Pointer(FInstance)).IsObject then
          begin
            vObj := vPrpRtti.GetValue(Pointer(FInstance)).AsObject;
            vPrpFKType := vPrpRtti.GetFKField(vObj);
            if vPrpFKType.getValue(vObj).asinteger = 0 then
              Continue;
          end
          else
          begin
            if vPrpRtti.GetValue(Pointer(FInstance)).AsInteger = 0 then
              Continue;
          end;
        end;
      end;
      aFields := aFields + vPrpRtti.FieldName + ', ';
    end;
  finally
    aFields := Copy(aFields, 0, Length(aFields) - 2) + ' ';
    vCtxRtti.Free;
  end;
end;

function TDataBaseRtti<T>.ValueIsNil(const pValue: TValue): Boolean;
begin
  case pValue.Kind of
    tkString, tkChar, tkWChar,
    tkLString, tkWString, tkUString:
      Result := Pointer(pValue.AsString) = nil;
    tkInteger, tkInt64:
      Result := Pointer(pValue.AsInteger) = nil;
    tkFloat:
    begin
      if pValue.TypeInfo = TypeInfo(TDateTime) then
        Result := Pointer(Trunc(pValue.asExtended)) = nil;
    end;
    tkClass:
      Result := Pointer(pValue.AsObject) = nil
    else
      Result := True;
  end;
end;

class function TDataBaseRtti<T>.New(pInstance: T): IDataBaseRtti<T>;
begin
  Result := Self.Create(pInstance);
end;

function TDataBaseRtti<T>.Param(var pParam: String): IDataBaseRtti<T>;
var
  vObj      : TObject;
  vCtxRtti  : TRttiContext;
  vTypRtti  : TRttiType;
  vPrpRtti,
  vPrpFKType: TRttiProperty;
begin
  Result := Self;

  vCtxRtti := TRttiContext.Create;
  try
    vTypRtti := vCtxRtti.GetType(FInstance.ClassInfo);
    for vPrpRtti in vTypRtti.GetProperties do
    begin
      if vPrpRtti.IsIgnore then
        Continue;

//      if vPrpRtti.IsAutoInc then
//        Continue;

      if FModeInsert and vPrpRtti.IsSequence then
      begin
        pParam := pParam + Format('nextval(%s), ', [QuotedStr(vPrpRtti.Sequence)]);
        Continue;
      end;

      if vPrpRtti.IsEnum then
      begin
        pParam := pParam + ':' + vPrpRtti.FieldName + '::' + vPrpRtti.EnumName + ', ';
        Continue;
      end;

      if vPrpRtti.IsForeignKey then
      begin
        begin
          if vPrpRtti.GetValue(Pointer(FInstance)).isobject then
          begin
            vObj := vPrpRtti.GetValue(Pointer(FInstance)).AsObject;
            vPrpFKType := vPrpRtti.GetFKField(vObj);
            if vPrpFKType.getValue(vObj).asinteger = 0 then
                Continue;
          end
          else
          begin
            if vPrpRtti.GetValue(Pointer(FInstance)).AsInteger = 0 then
              Continue;
          end;
        end;
      end;
      pParam  := pParam + ':' + vPrpRtti.FieldName + ', ';
    end;
  finally
    pParam := Copy(pParam, 0, Length(pParam) - 2) + ' ';
    vCtxRtti.Free;
  end;
end;

function TDataBaseRtti<T>.Sequence(var pSequence: String): IDataBaseRtti<T>;
var
  vTypRtti: TRttiType;
  vCtxRtti: TRttiContext;
begin
  Result := Self;
  vCtxRtti := TRttiContext.Create;
  try
    vTypRtti := vCtxRtti.GetType(FInstance.ClassInfo);
    if vTypRtti.Has<Seq> then
      pSequence := vTypRtti.GetAttribute<Seq>.Name;
  finally
    vCtxRtti.Free;
  end;
end;

function TDataBaseRtti<T>.TableName(var pTableName: String): IDataBaseRtti<T>;
var
  vTypRtti: TRttiType;
  vCtxRtti: TRttiContext;
begin
  Result   := Self;
  vCtxRtti := TRttiContext.Create;
  try
    vTypRtti := vCtxRtti.GetType(FInstance.ClassInfo);
    if vTypRtti.Has<Table> then
      pTableName := vTypRtti.GetAttribute<Table>.Name;
  finally
    vCtxRtti.Free;
  end;
end;

function TDataBaseRtti<T>.Update(var pUpdate: String): IDataBaseRtti<T>;
var
  vValue : TValue;
  vTypRtti : TRttiType;
  vCtxRtti : TRttiContext;
  vPrpRtti : TRttiProperty;
begin
  Result   := Self;
  vCtxRtti := TRttiContext.Create;
  try
    vTypRtti := vCtxRtti.GetType(FInstance.ClassInfo);

    for vPrpRtti in vTypRtti.GetProperties do
    begin
      vValue := vPrpRtti.GetValue(Pointer(FInstance));

      if vPrpRtti.IsIgnore then
        Continue;

      if vPrpRtti.IsAutoInc then
        Continue;

      if (not ValueIsNil(vValue)) then
      begin
        if vPrpRtti.IsEnum then
        begin
          pUpdate := pUpdate + vPrpRtti.FieldName + ' = :' + vPrpRtti.FieldName + '::' + vPrpRtti.EnumName + ', ';
          Continue;
        end;
        pUpdate := pUpdate + vPrpRtti.FieldName + ' = :' + vPrpRtti.FieldName + ', ';
      end;
    end;
  finally
    pUpdate := Copy(pUpdate, 0, Length(pUpdate) - 2) + ' ';
    vCtxRtti.Free;
  end;
end;

function TDataBaseRtti<T>.Values(pInstance: T; var pValues: String): IDataBaseRtti<T>;
var
  vCtxRtti: TRttiContext;
  vTypRtti: TRttiType;
  vPrpRtti: TRttiProperty;
begin
  Result   := Self;
  vCtxRtti := TRttiContext.Create;
  try
    vTypRtti := vCtxRtti.GetType(FInstance.ClassInfo);
    for vPrpRtti in vTypRtti.GetProperties do
    begin
      if vPrpRtti.IsIgnore then
        Continue;

//      if vPrpRtti.IsAutoInc then
//        Continue;
      if vPrpRtti.IsSequence then
      begin
        pValues := pValues + Format('nextval(%s), ', [QuotedStr(vPrpRtti.Sequence)]);
        Continue;
      end;

      pValues  := pValues + vPrpRtti.FieldName + '=' + vPrpRtti.GetValue(Pointer(pInstance)).AsString + ', ';
    end;
  finally
    pValues := Copy(pValues, 0, Length(pValues) - 2) + ' ';
    vCtxRtti.Free;
  end;
end;

function TDataBaseRtti<T>.Where(var pWhere: String): IDataBaseRtti<T>;
var
  vTypRtti: TRttiType;
  vCtxRtti: TRttiContext;
  vPrpRtti: TRttiProperty;
  vValue: TValue;
begin
  Result   := Self;
  vCtxRtti := TRttiContext.Create;
  try
    vTypRtti := vCtxRtti.GetType(FInstance.ClassInfo);
    for vPrpRtti in vTypRtti.GetProperties do
    begin
      vValue := vPrpRtti.GetValue(Pointer(FInstance));
      if vPrpRtti.IsPrimaryKey then
      begin
        if (vPrpRtti.IsEnum) then
          pWhere := pWhere + vPrpRtti.FieldName + ' = :' + vPrpRtti.FieldName + '::' + vPrpRtti.EnumName + ' AND '
        else
          if (not ValueIsNil(vValue)) then
            pWhere := pWhere + vPrpRtti.FieldName + ' = :' + vPrpRtti.FieldName + ' AND ';
      end
      else
      begin
        if (not ValueIsNil(vValue)) then
        begin
          if (vPrpRtti.IsEnum) then
            pWhere := pWhere + vPrpRtti.FieldName + ' = :' + vPrpRtti.FieldName + '::' + vPrpRtti.EnumName + ' AND '
          else
            pWhere := pWhere + vPrpRtti.FieldName + ' = :' + vPrpRtti.FieldName + ' AND ';
        end;
      end;
    end;
  finally
    pWhere := Copy(pWhere, 0, Length(pWhere) - 4) + ' ';
    vCtxRtti.Free;
  end;
end;

function TDataBaseRtti<T>._BindValueToComponent(pComponent: TComponent; pValue: Variant): IDataBaseRtti<T>;
begin
  if VarIsNull(pValue) then
      exit;
   {
  if pComponent is TAdvEdit then
      (pComponent as TAdvEdit).Text := pValue;

  if pComponent is TAdvComboBox then
      (pComponent as TAdvComboBox).ItemIndex := (pComponent as TAdvComboBox).Items.IndexOf(pValue);

  if pComponent is TRadioGroup then
      (pComponent as TRadioGroup).ItemIndex := (pComponent as TRadioGroup).Items.IndexOf(aValue);

  if pComponent is TShape then
      (pComponent as TShape).Brush.Color := aValue;

  //DateControls
  if pComponent is TAdvDateTimePicker then
      (pComponent as TAdvDateTimePicker).Date := aValue;

  if pComponent is TDateEdit then
      (pComponent as TDateEdit).Date := aValue;

  if pComponent is TAdvOfficeCheckBox then
      (pComponent as TAdvOfficeCheckBox).Checked := aValue;
      (pComponent as TAdvOfficeCheckBox).IsChecked := aValue;

  if pComponent is TTrackBar then
      (pComponent as TTrackBar).Position := aValue;
      }
end;

function TDataBaseRtti<T>._BindValueToProperty(pEntity: T; pProperty: TRttiProperty; pValue: TValue): IDataBaseRtti<T>;
begin
  case pProperty.PropertyType.TypeKind of
    tkUnknown: ;
    tkInteger:
      pProperty.SetValue(Pointer(pEntity), StrToInt(pValue.ToString));
    tkChar: ;
    tkEnumeration: ;
    tkFloat:
    begin
      if (pValue.TypeInfo    = TypeInfo(TDate))
         or (pValue.TypeInfo = TypeInfo(TTime))
         or (pValue.TypeInfo = TypeInfo(TDateTime)) then
      begin
        pProperty.SetValue(Pointer(pEntity), StrToDateTime(pValue.ToString))
      end
      else
        pProperty.SetValue(Pointer(pEntity), StrToFloat(pValue.ToString));
    end;
    tkSet: ;
    tkClass: ;
    tkMethod: ;
    tkString, tkWChar, tkLString, tkWString, tkVariant, tkUString:
      pProperty.SetValue(Pointer(pEntity), pValue);
    tkArray: ;
    tkRecord: ;
    tkInterface: ;
    tkInt64:
      pProperty.SetValue(Pointer(pEntity), pValue.Cast<Int64>);
    tkDynArray: ;
    tkClassRef: ;
    tkPointer: ;
    tkProcedure: ;
  else
    pProperty.SetValue(Pointer(pEntity), pValue);
  end;
end;

function TDataBaseRtti<T>._FloatFormat(pValue: String): Currency;
begin
  while Pos('.', pValue) > 0 do
    delete(pValue,Pos('.', pValue),1);

  Result := StrToCurr(pValue);
end;

function TDataBaseRtti<T>._GetComponentToValue(pComponent: TComponent): TValue;
begin
  if pComponent is TEdit then
    Result := TValue.FromVariant((pComponent as TEdit).Text);

  if pComponent is TAdvEdit then
    Result := TValue.FromVariant((pComponent as TAdvEdit).Text);

  if pComponent is TAdvComboBox then
    Result := TValue.FromVariant((pComponent as TAdvComboBox).Items[(pComponent as TAdvComboBox).ItemIndex]);

  if pComponent is TRadioGroup then
    Result := TValue.FromVariant((pComponent as TRadioGroup).Items[(pComponent as TRadioGroup).ItemIndex]);

  if pComponent is TShape then
    Result := TValue.FromVariant((pComponent as TShape).Brush.Color);

  if pComponent is TAdvOfficeCheckBox then
    Result := TValue.FromVariant((pComponent as TAdvOfficeCheckBox).Checked);

//  if pComponent is TTrackBar then
//    Result := TValue.FromVariant((pComponent as TTrackBar).Position);

//  if pComponent is TAdvDateTimePicker then
//    Result := TValue.FromVariant((pComponent as TAdvDateTimePicker).DateTime);

//  if pComponent is TDateEdit then
//    Result := TValue.FromVariant((pComponent as TDateEdit).DateTime);
end;

function TDataBaseRtti<T>._GetRttiProperty(pEntity: T; pPropertyName: String): TRttiProperty;
var
  vTypRttiEntity: TRttiType;
  vCtxRttiEntity: TRttiContext;
begin
  vCtxRttiEntity := TRttiContext.Create;
  try
    vTypRttiEntity := vCtxRttiEntity.GetType(pEntity.ClassInfo);
    Result := vTypRttiEntity.GetProperty(pPropertyName);

    if not Assigned(Result) then
      Result := vTypRttiEntity.GetPropertyFromAttribute<DBField>(pPropertyName);

    if not Assigned(Result) then
      raise EDataBaseRtti.Create('Property ' + pPropertyName + ' not found!');
  finally
    vCtxRttiEntity.Free;
  end;
end;

function TDataBaseRtti<T>._GetRttiPropertyValue(pEntity: T; pPropertyName: String): Variant;
begin
  Result := _GetRttiProperty(pEntity, pPropertyName).GetValue(Pointer(pEntity)).AsVariant;
end;

end.
