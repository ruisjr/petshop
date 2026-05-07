unit Controller.Especie;

interface

uses
  {Classes de Sistema}
   Horse
  ,Horse.Commons
  ,System.SysUtils
  {Classes de Negócio}
  ,Controller.Base;

type
  TControllerEspecie = class(TControllerBase)
  public
    procedure DoGetEspecie(Req: THorseRequest; Res: THorseResponse);
    procedure DoGetEspecies(Req: THorseRequest; Res: THorseResponse);
  end;

  procedure Registry;
  procedure UnRegistry;

var
  LController: TControllerEspecie;

implementation

uses
  {Classes de Sistema}
   System.JSON
  {Classes de Negócio}
  ,Core.Functions
  ,Services.Especie;

{ TControllerEspecie }

procedure TControllerEspecie.DoGetEspecie(Req: THorseRequest; Res: THorseResponse);
var
  LBody: TJsonObject;
  LService: TServiceEspecie;
begin
  LService := TServiceEspecie.Create;
  try
    try
      LBody := TJsonObject(TJsonObject.ParseJSONValue(Req.Body));
      try
        Self.ValidadeInfoRequest(LBody);
        Self.DoGet(LService.GetEspecie(LBody.GetValue<Integer>('id')), Res);
      finally
        LBody.ClearAndFreeItems;
      end;
    except
      on E: Exception do
        Self.DoGetError('Ocorreu erro ao processar a solicitação', E.Message, Res);
    end;
  finally
    FreeAndNil(LService);
  end;
end;

procedure TControllerEspecie.DoGetEspecies(Req: THorseRequest; Res: THorseResponse);
var
  LService: TServiceEspecie;
begin
  LService := TServiceEspecie.Create;
  try
    try
      Self.DoGet(LService.GetEspecies(), Res);
    except
      on E: Exception do
        Self.DoGetError('Ocorreu erro ao processar a solicitação', E.Message, Res);
    end;
  finally
    FreeAndNil(LService);
  end;
end;

procedure Registry;
begin
  LController := TControllerEspecie.Create;

  {Métodos Get}
  THorse.Get('/pet/especie', LController.DoGetEspecie);
  THorse.Get('/pet/especies', LController.DoGetEspecies);
end;

procedure UnRegistry;
begin
  if Assigned(LController) then
    FreeAndNil(LController);
end;

initialization;
  Registry;

finalization
  UnRegistry;

end.
