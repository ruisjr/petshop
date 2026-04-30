unit Services.Users;

interface

uses
  Horse;

implementation

uses
  {Classes de Sistema}
   System.JSON
  ,System.SysUtils
  {Classes de Negócio}
  ,Core.Global
  ,Core.Environment;


begin
  THorse.Get('/ping',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    begin
      Res.Send('{"response": true}');
      Res.Status(200);
      Env.Log.Debug('Endpoint: /ping | response: {"response": true}');
    end
  );

  THorse.Get('/users',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    var
      LJsonObj: TJSONObject;
    begin
      LJsonObj := TJSONObject.Create;
      try
        LJsonObj.AddPair('response', TJSONBool.Create(True));
        Res.Send(LJsonObj.ToJSON);
        REs.Status(200);
        Env.Log.Debug('Endpoint: /users | response: '+LJsonObj.ToJSON);
      finally
        FreeAndNil(LJsonObj);
      end;
    end
  );

  THorse.Post('/user',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    var
      LJsonObj: TJSONObject;
    begin
      LJsonObj := TJSONObject.Create;
      try
        Env.Log.Info(Req.Body);

        LJsonObj.AddPair('response', TJSONBool.Create(True));
        Res.Send(LJsonObj.ToJSON);
        REs.Status(200);
        Env.Log.Debug('Endpoint: /user | response: '+LJsonObj.ToJSON);
      finally
        FreeAndNil(LJsonObj);
      end;
    end
  );

  THorse.Listen(GetPortService);
end.
