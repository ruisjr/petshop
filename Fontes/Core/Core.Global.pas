unit Core.Global;

interface

Uses
  {Classes de Sistema}
   System.SysUtils
  ,System.Generics.Collections
  {Classes de Negócio}
  ,Entidade.ServInteg
  ,Entidade.DTO.Servidor
  ,Entidade.ServIntegParam
  ,Entidade.DTO.ServIntegParam
  ,Core.DataBase.Types
  ,Core.DataBase.Access
  ,Core.DataBase.Interfaces;


  function ObterParametros: TServIntegParamDTO;
  function ObterSeqServInteg: TServInteg;
  function ObterDataHoraServidor: TOraServidorDTO;

const
  cIntegracaoSimplus = 'SrvIntegracaoSimplus';
  cPathImagens = 'ImagemTemp';

var
  vgServInteg: TServInteg;
  vgIntegParam: TServIntegParamDTO;

implementation

function ObterParametros: TServIntegParamDTO;
const
  cSQL =
    'select *'#13+
    '  from (select (select vlr_param from serv_integ_param where chv_param = ''AuthUser'' and seq_serv_integ = :seq_serv_integ) auth_user_integ'#13+
    '             , (select vlr_param from serv_integ_param where chv_param = ''AuthPass'' and seq_serv_integ = :seq_serv_integ) auth_pass_integ'#13+
    '             , (select vlr_param from serv_integ_param where chv_param = ''DataUltExecut'' and seq_serv_integ = :seq_serv_integ) data_ult_execut_integ'#13+
    '             , (select vlr_param from serv_integ_param where chv_param = ''UrlLogin'' and seq_serv_integ = :seq_serv_integ) url_login_integ'#13+
    '             , (select vlr_param from serv_integ_param where chv_param = ''UrlListarProdutos'' and seq_serv_integ = :seq_serv_integ) url_listar_produtos_integ'#13+
    '             , (select vlr_param from serv_integ_param where chv_param = ''UrlBuscaInfoProduto'' and seq_serv_integ = :seq_serv_integ) url_busca_info_produto_integ'#13+
    '             , (select vlr_param from serv_integ_param where chv_param = ''UrlFindProduto'' and seq_serv_integ = :seq_serv_integ) url_find_produto_integ'#13+
    '             , (select vlr_param from serv_integ_param where chv_param = ''IntervaloEnvioSegundos'' and seq_serv_integ = :seq_serv_integ) intervalo_envio_segundos'#13+
    '             , (select vlr_param from serv_integ_param where chv_param = ''RegistrosSimultaneos'' and seq_serv_integ = :seq_serv_integ) registros_simultaneos'#13+
    '             , (select vlr_param from serv_integ_param where chv_param = ''EnviosSimultaneos'' and seq_serv_integ = :seq_serv_integ) envios_simultaneos'#13+
    '             , (select vlr_param from serv_integ_param where chv_param = ''EmailHost'' and seq_serv_integ = :seq_serv_integ) email_host'#13+
    '             , (select vlr_param from serv_integ_param where chv_param = ''EmailPort'' and seq_serv_integ = :seq_serv_integ) email_port'#13+
    '             , (select vlr_param from serv_integ_param where chv_param = ''EmailUserName'' and seq_serv_integ = :seq_serv_integ) email_username'#13+
    '             , (select vlr_param from serv_integ_param where chv_param = ''EmailPassword'' and seq_serv_integ = :seq_serv_integ) email_password'#13+
    '             , (select vlr_param from serv_integ_param where chv_param = ''EmailOrigem'' and seq_serv_integ = :seq_serv_integ) email_origem'#13+
    '             , (select vlr_param from serv_integ_param where chv_param = ''EmailDestino'' and seq_serv_integ = :seq_serv_integ) email_destino'#13+
    '          from dual) serv_dados_integ'#13+
    ' where auth_user_integ is not null';
var
  vDadosIntegDAO: IDataBaseDAO<TServIntegParamDTO>;
begin
  vDadosIntegDAO := TDataBaseDAO<TServIntegParamDTO>.Create;
  try
    Result := vDadosIntegDAO.SQL(cSQL)
                .Where('seq_serv_integ', otEqual, vgServInteg.SeqServInteg)
              .First;
  finally
    vDadosIntegDAO.FreeMemory;
  end;
end;

function ObterSeqServInteg: TServInteg;
var
  vServIntegDAO: IDataBaseDAO<TServInteg>;
begin
  vServIntegDAO := TDataBaseDAO<TServInteg>.Create;
  try
    Result := vServIntegDAO.Where('cod_serv_integ', otEqual, cIntegracaoSimplus).First;
  finally
    vServIntegDAO.FreeMemory;
  end;
end;

function ObterDataHoraServidor: TOraServidorDTO;
const
  cQuery =
    'select sysdate as data_hora'#13+
    '  from dual';
var
  vOraServidorDAO: IDataBaseDAO<TOraServidorDTO>;
begin
  vOraServidorDAO := TDataBaseDAO<TOraServidorDTO>.Create;
  try
    Result := vOraServidorDAO.SQL(cQuery).First;
  finally
    vOraServidorDAO.FreeMemory;
  end;
end;


initialization
  vgServInteg := ObterSeqServInteg;
  vgIntegParam := ObterParametros;

finalization
  if Assigned(vgIntegParam) then
    FreeAndNil(vgIntegParam);
  if Assigned(vgServInteg) then
    FreeAndNil(vgServInteg);

end.
