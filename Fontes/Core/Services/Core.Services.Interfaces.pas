unit Core.Services.Interfaces;

interface

uses
   Horse
  ,System.JSON;

type
  IController = interface
    ['{1173182C-A2D3-4ADB-94D4-CFF10F6A43B0}']
    {Procedures}
    procedure DoPost(Req: THorseRequest; Res: THorseResponse);
    procedure DoGet(Req: THorseRequest; Res: THorseResponse);

    procedure FreeMemory;
  end;

  IService = interface
    ['{DED15482-CD08-45A7-90D3-68787E2E6771}']
    {Functions}
    function GetService(const id: Integer): String;
    function GetServices(): String;

    function PostService(const ABody: TJSONObject): String;
  end;

implementation

end.
