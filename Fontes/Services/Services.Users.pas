unit Services.Users;

interface

uses
  Horse;

implementation

uses
  Core.Environment;

begin
  THorse.Get('/ping',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    begin
      Res.Send('pong');
      Res.Status(200);
      gEnv.Log.Debug('Endpoint: /ping');
    end);

  THorse.Listen(9000);

end.
